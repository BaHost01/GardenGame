import pygame import sys import random import json import os import traceback import hashlib

Constants

WIDTH, HEIGHT = 800, 600 FPS = 60 ASSET_DIR = 'assets' SAVE_FILE = 'savegame.json' KEYBINDS_FILE = 'keybinds.json' SETTINGS_FILE = 'settings.json'

Default configs

default_keybinds = { 'plant': '1', 'water': '2', 'next_day': '3', 'shop': '4', 'gear': '5', 'quit': '6' } default_settings = { 'volume': 0.5, 'checksum': '' }

Data definitions

PLANTS = { 'tomato': {'grow': 3, 'yield': (2, 5), 'price': 5,  'img': 'tomato.png',      'premium': False}, 'carrot': {'grow': 2, 'yield': (1, 3), 'price': 3,  'img': 'carrot.png',      'premium': False}, 'strawberry': {'grow': 4, 'yield': (3, 6), 'price': 8,  'img': 'strawberry.png', 'premium': False}, 'mystic': {'grow': 5, 'yield': (5,10),'price': 20, 'img': 'mystic_seed.png', 'premium': True}, 'blueberry': {'grow': 4, 'yield': (2, 7), 'price':12,  'img': 'blueberry.png',   'premium': True} } GEAR = { 'watering_can': {'price':50, 'effect':'auto_water',    'premium': False}, 'sprinkler':    {'price':150,'effect':'area_water',    'premium': False}, 'scarecrow':    {'price':200,'effect':'pest_protect',  'premium': False}, 'fertilizer':   {'price':100,'effect':'fast_growth',   'premium': True}, 'greenhouse':   {'price':500,'effect':'year_round',    'premium': True} }

JSON utilities

def load_json(path, default): if not os.path.exists(path): save_json(path, default) return default.copy() try: with open(path, 'r') as f: return json.load(f) except Exception: return default.copy()

def save_json(path, data): try: with open(path, 'w') as f: json.dump(data, f, indent=4) except Exception: traceback.print_exc()

Anticheat

def checksum(path): try: with open(path, 'rb') as f: return hashlib.sha256(f.read()).hexdigest() except Exception: return ''

def verify_settings(): settings = load_json(SETTINGS_FILE, default_settings) stored = settings.get('checksum', '') current = checksum(SETTINGS_FILE) if stored and stored != current: raise RuntimeError('Settings tampered') settings['checksum'] = current save_json(SETTINGS_FILE, settings)

Main Game

class Game: def init(self): pygame.init() self.screen = pygame.display.set_mode((WIDTH, HEIGHT)) pygame.display.set_caption('Gardening Tycoon') self.clock = pygame.time.Clock() verify_settings() self.keybinds = load_json(KEYBINDS_FILE, default_keybinds) self.settings = load_json(SETTINGS_FILE, default_settings) self.day = 1 self.money = 100 self.premium = False self.inventory = {} self.plots = [None] * 6 self.gear = [] self.state = 'menu' self.load_assets() from customtinker import Panel, Button, Label self.Panel, self.Button, self.Label = Panel, Button, Label self.ui = {} self.setup_ui() self.load_game()

def load_assets(self):
    self.images = {}
    for key, spec in {**PLANTS, **GEAR}.items():
        img = spec.get('img')
        if img:
            path = os.path.join(ASSET_DIR, img)
            try:
                self.images[key] = pygame.image.load(path)
            except Exception:
                self.images[key] = None

def setup_ui(self):
    menu = self.Panel()
    menu.add(self.Label('Gardening Tycoon', (280, 100), size=48))
    menu.add(self.Button('Start Game', (320, 200), callback=lambda: self.set_state('garden')))
    menu.add(self.Button('Seed Shop', (320, 260), callback=lambda: self.set_state('shop')))
    menu.add(self.Button('Gear Shop', (320, 320), callback=lambda: self.set_state('gear')))
    menu.add(self.Button('Quit',      (320, 380), callback=self.exit_game))
    self.ui['menu'] = menu

    garden = self.Panel()
    garden.add(self.Label(lambda: f'Day {self.day}',   (20,20)))
    garden.add(self.Label(lambda: f'Money: ${self.money}', (20,60)))
    garden.add(self.Button('Next Day', (650,150), callback=self.next_day))
    garden.add(self.Button('Plant',    (650,210), callback=self.plant_cycle))
    garden.add(self.Button('Water',    (650,270), callback=self.water_cycle))
    garden.add(self.Button('Menu',     (650,330), callback=lambda: self.set_state('menu')))
    self.ui['garden'] = garden

    shop = self.Panel()
    shop.add(self.Label('Seed Shop', (50,30), size=36))
    y = 100
    for name, spec in PLANTS.items():
        if spec['premium'] and not self.premium:
            continue
        price = spec['price']
        shop.add(self.Label(f"{name.capitalize()} - ${price}", (50,y)))
        shop.add(self.Button('Buy', (200,y), callback=lambda n=name: self.buy_seed(n)))
        y += 50
    shop.add(self.Button('Back', (650,500), callback=lambda: self.set_state('menu')))
    self.ui['shop'] = shop

    gear = self.Panel()
    gear.add(self.Label('Gear Shop', (50,30), size=36))
    y = 100
    for name, spec in GEAR.items():
        if spec['premium'] and not self.premium:
            continue
        gear.add(self.Label(f"{name.replace('_',' ').capitalize()} - ${spec['price']}", (50,y)))
        gear.add(self.Button('Buy', (250,y), callback=lambda n=name: self.buy_gear(n)))
        y += 50
    gear.add(self.Button('Back', (650,500), callback=lambda: self.set_state('menu')))
    self.ui['gear'] = gear

def set_state(self, state):
    self.state = state

def exit_game(self):
    self.save_game()
    pygame.quit()
    sys.exit(0)

def load_game(self):
    data = load_json(SAVE_FILE, {})
    for attr in ['day','money','premium','inventory','plots','gear']:
        setattr(self, attr, data.get(attr, getattr(self, attr)))

def save_game(self):
    data = {k: getattr(self, k) for k in ['day','money','premium','inventory','plots','gear']}
    save_json(SAVE_FILE, data)

def next_day(self):
    if random.random() < 0.2:
        self.auto_water()
    if random.random() < 0.1:
        self.pest_event()
    for i, p in enumerate(self.plots):
        if p:
            if p.get('watered') or 'auto_water' in self.gear:
                p['days'] += 1
                p['watered'] = False
            if p['days'] >= p['grow']:
                qty = random.randint(*p['yield'])
                earned = qty * p['price'] * (2 if self.premium else 1)
                self.money += earned
                self.plots[i] = None
    self.day += 1

def auto_water(self):
    for p in self.plots:
        if p:
            p['watered'] = True

def pest_event(self):
    occupied = [i for i, p in enumerate(self.plots) if p]
    if occupied:
        self.plots[random.choice(occupied)] = None

def plant_cycle(self):
    for seed, qty in list(self.inventory.items()):
        if qty > 0:
            for i, p in enumerate(self.plots):
                if not p:
                    spec = PLANTS[seed]
                    self.plots[i] = {'type': seed, 'days': 0, 'grow': spec['grow'],
                                     'yield': spec['yield'], 'price': spec['price'], 'watered': False}
                    self.inventory[seed] -= 1
                    return

def water_cycle(self):
    for p in self.plots:
        if p and not p['watered']:
            p['watered'] = True
            return

def buy_seed(self, name):
    spec = PLANTS[name]
    if spec['premium'] and not self.premium:
        return
    if self.money >= spec['price']:
        self.money -= spec['price']
        self.inventory[name] = self.inventory.get(name, 0) + 1

def buy_gear(self, name):
    spec = GEAR[name]
    if spec['premium'] and not self.premium:
        return
    if self.money >= spec['price']:
        self.money -= spec['price']
        self.gear.append(spec['effect'])

def draw(self):
    self.screen.fill((30,150,30))
    if self.state in ('garden','menu'):
        self.screen.blit(self.images.get('garden_bg', pygame.Surface((0,0))), (0,0))
    elif self.state == 'shop':
        self.screen.blit(self.images.get('shop_bg', pygame.Surface((0,0))), (0,0))
    elif self.state == 'gear':
        self.screen.fill((100,100,100))
    if self.state == 'garden':
        for i, pos in enumerate([(100+i*120,350) for i in range(len(self.plots))]):
            self.screen.blit(self.spot, pos)
            p = self.plots[i]
            if p:
                img = self.images.get(p['type'])
                if img:
                    self.screen.blit(img, pos)
    self.ui[self.state].draw(self.screen)
    pygame.display.flip()

def handle_events(self):
    for e in pygame.event.get():
        if e.type == pygame.QUIT:
            self.exit_game()
        self.ui[self.state].handle_event(e)

def run(self):
    try:
        while True:
            self.handle_events()
            self.draw()
            self.clock.tick(FPS)
    except Exception:
        traceback.print_exc()
        pygame.quit()
        sys.exit(1)

if name == 'main': save_json(KEYBINDS_FILE, default_keybinds) save_json(SETTINGS_FILE, default_settings) Game().run()

