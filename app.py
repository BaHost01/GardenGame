import pygame import sys import random import json import os

Constants\ nWIDTH, HEIGHT = 800, 600

FPS = 60 SAVE_FILE = 'savegame.json'

Colors

WHITE = (255,255,255) BLACK = (0,0,0)

Initialize pygame and customtinker

pygame.init() from customtinker import Button, Panel, Label, Image  # hypothetical

screen = pygame.display.set_mode((WIDTH, HEIGHT)) clock = pygame.time.Clock()

Load assets

BACKGROUND = pygame.image.load('assets/garden_bg.png') TREE_IMG = pygame.image.load('assets/plant_spot.png') SHOP_IMG = pygame.image.load('assets/shop_bg.png')

Plant definitions\ nPLANTS = {

'tomato': {'grow_time':3, 'yield':(2,5), 'price':5, 'img':'assets/tomato.png', 'premium_only':False},
'mystic': {'grow_time':5, 'yield':(5,10), 'price':20, 'img':'assets/mystic_seed.png', 'premium_only':True}

}

Gear items\ nGEAR = {

'watering_can': {'price':50, 'effect':'auto_water'},
'fertilizer': {'price':100, 'effect':'faster_growth', 'premium_only':True}

}

class Game: def init(self): self.day = 1 self.money = 100 self.premium = False self.inventory = {} self.plots = [None]*5  # 5 spots self.gear = [] self.load() # UI panels self.main_menu = Panel()  # will hold buttons self.garden_panel = Panel() self.shop_panel = Panel() self.gear_panel = Panel() self.setup_ui() self.state = 'garden'

def setup_ui(self):
    # Main Garden Buttons
    self.btn_next = Button('Next Day', (650,500), callback=self.next_day)
    self.btn_shop = Button('Seed Shop', (650,450), callback=lambda:self.change_state('shop'))
    self.btn_gear = Button('Gear Shop', (650,400), callback=lambda:self.change_state('gear'))
    self.btn_premium = Button('Go Premium', (650,350), callback=self.upgrade_premium)
    self.main_menu.add(self.btn_next, self.btn_shop, self.btn_gear, self.btn_premium)

def change_state(self, st): self.state = st

def upgrade_premium(self):
    # simplistic unlock
    if self.money>=200:
        self.money-=200
        self.premium=True
        print('Premium unlocked! Exclusive seeds and gear available.')

def load(self):
    if os.path.exists(SAVE_FILE):
        data=json.load(open(SAVE_FILE))
        self.__dict__.update(data)
        print('Loaded')

def save(self):
    data={k:v for k,v in self.__dict__.items() if k in ['day','money','premium','inventory','plots','gear']}
    json.dump(data, open(SAVE_FILE,'w'))

def next_day(self):
    # growth and events\ n        for i,plant in enumerate(self.plots):
        if plant:
            if 'auto_water' in self.gear:
                plant['watered']=True
            if plant['watered']:
                plant['days']+=1
                plant['watered']=False
            if plant['days']>=plant['grow_time']:
                qty=random.randint(*plant['yield'])
                if self.premium: qty*=2
                self.money+=qty*plant['price']
                self.plots[i]=None
    self.day+=1

def plant(self,index, seed):
    spec=PLANTS[seed]
    if spec['premium_only'] and not self.premium: return
    if self.money<spec['price'] or self.plots[index]: return
    self.money-=spec['price']
    self.plots[index]={'type':seed,'days':0,'grow_time':spec['grow_time'],'yield':spec['yield'],'price':spec['price'],'watered':False}

def water(self,index):
    if self.plots[index]: self.plots[index]['watered']=True

def buy_seed(self,seed):
    spec=PLANTS[seed]
    if spec['premium_only'] and not self.premium: return
    if self.money<spec['price']: return
    self.money-=spec['price']
    self.inventory[seed]=self.inventory.get(seed,0)+1

def buy_gear(self,item):
    spec=GEAR[item]
    if spec.get('premium_only') and not self.premium: return
    if self.money<spec['price']: return
    self.money-=spec['price']
    self.gear.append(spec['effect'])

def draw_garden(self):
    screen.blit(BACKGROUND, (0,0))
    for i,pos in enumerate([(100+120*i,300) for i in range(5)]]):
        screen.blit(TREE_IMG, pos)
        plant=self.plots[i]
        if plant:
            img=pygame.image.load(PLANTS[plant['type']]['img'])
            screen.blit(img,pos)
    self.main_menu.draw(screen)

def draw_shop(self):
    screen.blit(SHOP_IMG, (0,0))
    y=100
    for seed,spec in PLANTS.items():
        if spec['premium_only'] and not self.premium: continue
        Label(f"{seed} - ${spec['price']}", (50,y)).draw(screen)
        Button('Buy', (200,y), callback=lambda s=seed:self.buy_seed(s)).draw(screen)
        y+=50
    Button('Back', (650,550), callback=lambda:self.change_state('garden')).draw(screen)

def draw_gear(self):
    screen.fill(WHITE)
    y=100
    for item,spec in GEAR.items():
        if spec.get('premium_only') and not self.premium: continue
        Label(f"{item} - ${spec['price']}", (50,y)).draw(screen)
        Button('Buy', (200,y), callback=lambda i=item:self.buy_gear(i)).draw(screen)
        y+=50
    Button('Back', (650,550), callback=lambda:self.change_state('garden')).draw(screen)

def run(self):
    while True:
        for e in pygame.event.get():
            if e.type==pygame.QUIT: sys.exit()
            if self.state=='garden': self.main_menu.handle_event(e)
        if self.state=='garden': self.draw_garden()
        elif self.state=='shop': self.draw_shop()
        elif self.state=='gear': self.draw_gear()
        pygame.display.flip()
        clock.tick(FPS)

if name=='main': Game().run()

