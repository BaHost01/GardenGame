import pygame
import sys
import random
import json
import os
import traceback
import hashlib

SAVE_FILE = 'savegame.json' KEYBIND_FILE = 'keybinds.json' SETTINGS_FILE = 'settings.json' ASSET_DIR = 'assets' WIDTH, HEIGHT = 800, 600 FPS = 60

def load_json(path, default): if not os.path.exists(path): save_json(path, default) return default.copy() try: with open(path, 'r') as f: return json.load(f) except: return default.copy()

def save_json(path, data): try: with open(path, 'w') as f: json.dump(data, f, indent=4) except Exception: traceback.print_exc()

def checksum(path): try: with open(path, 'rb') as f: return hashlib.sha256(f.read()).hexdigest() except: return ''

def verify_settings(): settings = load_json(SETTINGS_FILE, {'volume': 0.5, 'anticheat_checksum': ''}) stored = settings.get('anticheat_checksum', '') current = checksum(SETTINGS_FILE) if stored and stored != current: raise RuntimeError('Settings tampered') settings['anticheat_checksum'] = current save_json(SETTINGS_FILE, settings)

PLANTS = { 'tomato': {'grow_time': 3, 'yield': (2, 5), 'price': 5, 'img': 'tomato.png', 'premium': False}, 'mystic': {'grow_time': 5, 'yield': (5, 10), 'price': 20, 'img': 'mystic_seed.png', 'premium': True}, 'carrot': {'grow_time': 2, 'yield': (1, 3), 'price': 3, 'img': 'carrot.png', 'premium': False}, 'strawberry': {'grow_time': 4, 'yield': (3, 6), 'price': 8, 'img': 'strawberry.png', 'premium': False}, 'corn': {'grow_time': 5, 'yield': (4, 8), 'price': 10, 'img': 'corn.png', 'premium': False}, 'blueberry': {'grow_time': 4, 'yield': (2, 7), 'price': 12, 'img': 'blueberry.png', 'premium': True} } GEAR = { 'watering_can': {'price': 50, 'effect': 'auto_water', 'premium': False}, 'fertilizer': {'price': 100, 'effect': 'fast_growth', 'premium': True}, 'sprinkler': {'price': 150, 'effect': 'area_water', 'premium': False}, 'scarecrow': {'price': 200, 'effect': 'pest_protect', 'premium': False}, 'greenhouse': {'price': 500, 'effect': 'year_round', 'premium': True} }

def create_default_files(): load_json(KEYBIND_FILE, {'plant': '1', 'water': '2', 'next_day': '3', 'harvest': '4', 'shop': '5', 'gear_shop': '6', 'premium': '7'}) load_json(SETTINGS_FILE, {'volume': 0.5, 'anticheat_checksum': ''})

class Game: def init(self): pygame.init() self.screen = pygame.display.set_mode((WIDTH, HEIGHT)) pygame.display.set_caption('Gardening Tycoon') self.clock = pygame.time.Clock() verify_settings() self.keybinds = load_json(KEYBIND_FILE, {}) self.settings = load_json(SETTINGS_FILE, {}) self.day = 1 self.money = 100 self.premium = False self.inventory = {} self.plots = [None] * 6 self.gear = [] self.state = 'main' self.load_assets() from customtinker import Panel, Button, Label self.Panel = Panel self.Button = Button self.Label = Label self.ui = {} self.setup_ui() self.load_game()

def load_assets(self):
    self.bg = pygame.image.load(os.path.join(ASSET_DIR, 'garden_bg.png'))
    self.spot = pygame.image.load(os.path.join(ASSET_DIR, 'plant_spot.png'))
    self.shop_bg = pygame.image.load(os.path.join(ASSET_DIR, 'shop_bg.png'))

def setup_ui(self):
    main = self.Panel()
    main.add(self.Label('Gardening Tycoon', (250, 100), size=48))
    main.add(self.Button('Enter Garden', (300, 200), callback=lambda: self.set_state('garden')))
    main.add(self.Button('Seed Shop', (300, 260), callback=lambda: self.set_state('shop')))
    main.add(self.Button('Gear Shop', (300, 320), callback=lambda: self.set_state('gear')))
    main.add(self.Button('Quit', (300, 380), callback=self.exit_game))
    self.ui['main'] = main
    garden = self.Panel()
    garden.add(self.Label(lambda: f'Day {self.day}', (20, 20)))
    garden.add(self.Label(lambda: f'Money: ${self.money}', (20, 60)))
    actions = [
        ('Next Day', self.next_day),
        ('Plant', self.plant_cycle),
        ('Water', self.water_cycle),
        ('Back', lambda: self.set_state('main'))
    ]
    for i, (text, cb) in enumerate(actions):
        garden.add(self.Button(text, (650, 150 + i * 60), callback=cb))
    self.ui['garden'] = garden
    shop = self.Panel()
    shop.add(self.Label('Seed Shop', (50, 30), size=36))
    y = 100
    for seed, spec in PLANTS.items():
        if spec['premium'] and not self.premium:
            continue
        shop.add(self.Label(f"{seed.capitalize()} - ${spec['price']}", (50, y)))
        shop.add(self.Button('Buy', (250, y), callback=lambda sd=seed: self.buy_seed(sd)))
        y += 50
    shop.add(self.Button('Back', (650, 500), callback=lambda: self.set_state('main')))
    self.ui['shop'] = shop
    gearp = self.Panel()
    gearp.add(self.Label('Gear Shop', (50, 30), size=36))
    y = 100
    for item, spec in GEAR.items():
        if spec['premium'] and not self.premium:
            continue
        gearp.add(self.Label(f"{item.replace('_', ' ').capitalize()} - ${spec['price']}", (50, y)))
        gearp.add(self.Button('Buy', (250, y), callback=lambda it=item: self.buy_gear(it)))
        y += 50
    gearp.add(self.Button('Back', (650, 500), callback=lambda: self.set_state('main')))
    self.ui['gear'] = gearp

def set_state(self, state):
    self.state = state

def exit_game(self):
    self.save_game()
    pygame.quit()
    sys.exit(0)

def load_game(self):
    data = load_json(SAVE_FILE, {})
    for key in ['day', 'money', 'premium', 'inventory', 'plots', 'gear']:
        setattr(self, key, data.get(key, getattr(self, key)))

def save_game(self):
    save_json(
        SAVE_FILE,
        {
            'day': self.day,
            'money': self.money,
            'premium': self.premium,
            'inventory': self.inventory,
            'plots': self.plots,
            'gear': self.gear,
        }
    )

def next_day(self):
    ev = random.choice(['rain', 'pests', 'none'])
    if ev == 'rain':
        self.auto_water()
    if ev == 'pests':
        self.pest_event()
    for i, plot in enumerate(self.plots):
        if plot:
            if 'auto_water' in self.gear:
                plot['watered'] = True
            if plot['watered']:
                plot['days'] += 1
                plot['watered'] = False
            if plot['days'] >= plot['grow_time']:
                qty = random.randint(*plot['yield'])
                earn = qty * plot['price'] * (2 if self.premium else 1)
                self.money += earn
                self.plots[i] = None
    self.day += 1

def auto_water(self):
    for plot in self.plots:
        if plot:
            plot['watered'] = True

def pest_event(self):
    occupied = [i for i, plot in enumerate(self.plots) if plot]
    if occupied:
        victim = random.choice(occupied)
        self.plots[victim] = None

def plant_cycle(self):
    for seed, qty in list(self.inventory.items()):
        if qty > 0:
            for i, plot in enumerate(self.plots):
                if not plot:
                    self.inventory[seed] -= 1
                    spec = PLANTS[seed]
                    self.plots[i] = {
                        'type': seed,
                        'days': 0,
                        'grow_time': spec['grow_time'],
                        'yield': spec['yield'],
                        'price': spec['price'],
                        'watered': False,
                    }
                    return

def water_cycle(self):
    for i, plot in enumerate(self.plots):
        if plot and not plot['watered']:
            plot['watered'] = True
            return

def buy_seed(self, seed):
    spec = PLANTS[seed]
    if spec['premium'] and not self.premium:
        return
    if self.money < spec['price']:
        return
    self.money -= spec['price']
    self.inventory[seed] = self.inventory.get(seed, 0) + 1

def buy_gear(self, item):
    spec = GEAR[item]
    if spec['premium'] and not self.premium:
        return
    if self.money < spec['price']:
        return
    self.money -= spec['price']
    self.gear.append(spec['effect'])

def draw(self):
    if self.state == 'main':
        self.screen.fill((30, 160, 30))
    elif self.state == 'garden':
        self.screen.blit(self.bg, (0, 0))
        for idx, pos in enumerate([(100 + i * 120, 350) for i in range(len(self.plots))]):
            self.screen.blit(self.spot, pos)
            plot = self.plots[idx]
            if plot:
                img = pygame.image.load(os.path.join(ASSET_DIR, PLANTS[plot['type']]['img']))
                self.screen.blit(img, pos)
    elif self.state == 'shop':
        self.screen.blit(self.shop_bg, (0, 0))
    elif self.state == 'gear':
        self.screen.fill((100, 100, 100))
    self.ui[self.state].draw(self.screen)
    pygame.display.flip()

def handle_events(self):
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            self.exit_game()
        self.ui[self.state].handle_event(event)

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

if name == 'main': create_default_files() Game().run()

