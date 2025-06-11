import pygame
import sys
import json
import random
import traceback
from datetime import datetime

pygame.init()
WIDTH, HEIGHT = 1024, 768
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption('Gardening Tycoon 2D')
clock = pygame.time.Clock()

from customtinker import Panel, Button, Label

def default_player():
    return {'money': 500, 'inventory': {}, 'gear': [], 'premium': False}

def get_seeds():
    names = ['carrot','tomato','lettuce','strawberry','corn','blueberry','pepper','eggplant','onion','potato','pumpkin','cucumber','spinach','radish','beet']
    return {n:{'cost':10+5*i,'grow':3+i%5,'sell':20+10*i,'color':(random.randint(50,255),random.randint(50,255),random.randint(50,255))} for i,n in enumerate(names)}

def get_gear():
    items = ['sprinkler','fertilizer','scarecrow','greenhouse','harvester']
    effects = ['water_all','fast_grow','pest_protect','double_harvest','auto_harvest']
    return {items[i]:{'cost':200+100*i,'effect':effects[i],'label':items[i].capitalize()} for i in range(5)}

def load_json(path, default):
    try:
        with open(path,'r') as f: return json.load(f)
    except:
        data = default()
        save_json(path,data)
        return data

def save_json(path,data):
    with open(path,'w') as f: json.dump(data,f,indent=4)

class Plant:
    def __init__(self, kind, data):
        self.kind=kind; self.data=data; self.age=0; self.ready=False
    def grow(self):
        if not self.ready:
            self.age+=1
            if self.age>=self.data['grow']: self.ready=True

class Game:
    def __init__(self):
        self.player = load_json('save.json',default_player)
        self.seeds = get_seeds()
        self.gear = get_gear()
        self.farm = [[None]*10 for _ in range(6)]
        self.state='menu'; self.selected_seed=None
        self.setup_ui()

    def setup_ui(self):
        self.panels={}
        p=Panel(); p.add(Label('Gardening Tycoon',(350,100),size=48));
        p.add(Button('Play',(400,300),self.start_game)); p.add(Button('Shop',(400,360),self.open_shop));
        p.add(Button('Gear',(400,420),self.open_gear)); p.add(Button('Quit',(400,480),self.exit_game)); self.panels['menu']=p
        pf=Panel(); pf.add(Label(lambda:f"Money: ${self.player['money']}",(800,10)));
        pf.add(Button('Back',(900,10),self.back_menu)); self.panels['play']=pf
        ps=Panel(); ps.add(Label('Seed Shop',(50,50),size=36)); y=120
        for name,data in self.seeds.items():
            ps.add(Label(f"{name.capitalize()} - ${data['cost']}",(50,y)))
            ps.add(Button('Buy',(300,y),lambda n=name:self.buy_seed(n))); y+=40
        ps.add(Button('Back',(900,10),self.back_menu)); self.panels['shop']=ps
        pg=Panel(); pg.add(Label('Gear Shop',(50,50),size=36)); y=120
        for name,data in self.gear.items():
            pg.add(Label(f"{data['label']} - ${data['cost']}",(50,y)))
            pg.add(Button('Buy',(300,y),lambda n=name:self.buy_gear(n))); y+=40
        pg.add(Button('Back',(900,10),self.back_menu)); self.panels['gear']=pg

    def start_game(self): self.state='play'
    def open_shop(self): self.state='shop'
    def open_gear(self): self.state='gear'
    def back_menu(self): self.state='menu'; self.selected_seed=None
    def exit_game(self): save_json('save.json',self.player); pygame.quit(); sys.exit(0)

    def buy_seed(self,name):
        cost=self.seeds[name]['cost']
        if self.player['money']>=cost:
            self.player['money']-=cost; self.player['inventory'][name]=self.player['inventory'].get(name,0)+1; self.selected_seed=name

    def buy_gear(self,name):
        cost=self.gear[name]['cost']
        if self.player['money']>=cost:
            self.player['money']-=cost; self.player['gear'].append(self.gear[name]['effect'])

    def run(self):
        try:
            while True:
                for e in pygame.event.get():
                    if e.type==pygame.QUIT: self.exit_game()
                    self.panels[self.state].handle_event(e)
                    if self.state=='play' and e.type==pygame.MOUSEBUTTONDOWN:
                        x,y=e.pos; row=y//100; col=x//100
                        if row<6 and col<10:
                            plant=self.farm[row][col]
                            if plant and plant.ready:
                                mult=2 if 'double_harvest' in self.player['gear'] else 1
                                self.player['money']+=plant.data['sell']*mult; self.farm[row][col]=None
                            elif plant is None and self.selected_seed:
                                if self.player['inventory'].get(self.selected_seed,0)>0:
                                    self.player['inventory'][self.selected_seed]-=1
                                    self.farm[row][col]=Plant(self.selected_seed,self.seeds[self.selected_seed])
                if self.state=='play':
                    for row in self.farm:
                        for plant in row:
                            if plant: plant.grow()
                screen.fill(WHITE)
                if self.state=='play':
                    for i,row in enumerate(self.farm):
                        for j,plant in enumerate(row):
                            rect=pygame.Rect(j*100,i*100,100,100); pygame.draw.rect(screen,BLACK,rect,1)
                            if plant:
                                c=plant.data['color']; r=40 if plant.ready else int(40*plant.age/plant.data['grow'])
                                pygame.draw.circle(screen,c,rect.center,r)
                self.panels[self.state].draw(screen)
                pygame.display.flip(); clock.tick(FPS)
        except Exception:
            with open('error.log','a') as f: f.write(f"{datetime.now()} - {traceback.format_exc()}\n")
            pygame.quit(); sys.exit(1)

if __name__=='__main__':
    Game().run()
