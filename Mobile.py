from kivy.app import App from kivy.lang import Builder from kivy.uix.screenmanager import ScreenManager, Screen from kivy.uix.gridlayout import GridLayout from kivy.uix.boxlayout import BoxLayout from kivy.uix.button import Button from kivy.uix.label import Label from kivy.clock import Clock from kivy.storage.jsonstore import JsonStore from kivy.properties import StringProperty, NumericProperty, ObjectProperty import random

KV = ''' ScreenManager: MenuScreen: FarmScreen: SeedShopScreen: GearShopScreen:

<MenuScreen>: name: 'menu' BoxLayout: orientation: 'vertical' spacing: dp(20) padding: dp(40) Label: text: 'Gardening Tycoon Mobile' font_size: '32sp' Button: text: 'Start Farming' on_release: root.manager.current = 'farm' Button: text: 'Seed Shop' on_release: root.manager.current = 'seed_shop' Button: text: 'Gear Shop' on_release: root.manager.current = 'gear_shop' Button: text: 'Exit' on_release: app.stop()

<FarmScreen>: name: 'farm' BoxLayout: orientation: 'vertical' size: root.size BoxLayout: size_hint_y: None height: dp(40) Label: text: root.money_text Button: text: 'Back' on_release: root.manager.current = 'menu' GridLayout: id: farm_grid cols: 5 rows: 3 spacing: dp(5) padding: dp(5) BoxLayout: size_hint_y: None height: dp(60) Label: text: 'Selected: ' + (root.selected or 'None') Button: text: 'Clear' on_release: root.clear_selection()

<SeedShopScreen>: name: 'seed_shop' BoxLayout: orientation: 'vertical' BoxLayout: size_hint_y: None height: dp(40) Button: text: 'Back' on_release: root.manager.current = 'menu' ScrollView: GridLayout: id: seed_grid cols: 1 size_hint_y: None height: self.minimum_height padding: dp(10) spacing: dp(10)

<GearShopScreen>: name: 'gear_shop' BoxLayout: orientation: 'vertical' BoxLayout: size_hint_y: None height: dp(40) Button: text: 'Back' on_release: root.manager.current = 'menu' ScrollView: GridLayout: id: gear_grid cols: 1 size_hint_y: None height: self.minimum_height padding: dp(10) spacing: dp(10) '''

class MenuScreen(Screen): pass

class FarmPlot(Button): crop = StringProperty('') age = NumericProperty(0) grow_time = NumericProperty(0) sell_price = NumericProperty(0)

def on_release(self):
    app = App.get_running_app()
    farm_screen = app.sm.get_screen('farm')
    if self.crop:
        if self.age >= self.grow_time:
            app.game.money += self.sell_price
            self.reset_plot()
            farm_screen.update_ui()
    else:
        if farm_screen.selected and app.game.inventory.get(farm_screen.selected,0) > 0:
            spec = app.game.seeds[farm_screen.selected]
            app.game.inventory[farm_screen.selected] -= 1
            self.plant(farm_screen.selected, spec)
            farm_screen.update_ui()

def plant(self, name, spec):
    self.crop = name
    self.age = 0
    self.grow_time = spec['grow']
    self.sell_price = spec['sell']
    self.background_color = spec['color']

def grow(self, dt):
    if self.crop:
        self.age += dt
        if self.age >= self.grow_time:
            self.background_color = (0,1,0,1)

def reset_plot(self):
    self.crop = ''
    self.age = 0
    self.grow_time = 0
    self.sell_price = 0
    self.background_color = (1,1,1,1)

class FarmScreen(Screen): selected = StringProperty('') money_text = StringProperty('') def on_enter(self): self.build_farm() self.update_ui()

def build_farm(self):
    grid = self.ids.farm_grid
    grid.clear_widgets()
    for _ in range(15):
        p = FarmPlot()
        grid.add_widget(p)
        Clock.schedule_interval(p.grow, 1)

def update_ui(self):
    self.money_text = f"Money: ${App.get_running_app().game.money:.0f}"

def clear_selection(self):
    self.selected = ''

class SeedShopScreen(Screen): def on_enter(self): grid = self.ids.seed_grid grid.clear_widgets() app = App.get_running_app() for name,spec in app.game.seeds.items(): btn = Button(text=f"{name.capitalize()} - Cost: ${spec['cost']}", size_hint_y=None, height=dp(40)) btn.bind(on_release=lambda btn,n=name: self.buy(n)) grid.add_widget(btn)

def buy(self,name):
    app = App.get_running_app()
    if app.game.money >= app.game.seeds[name]['cost']:
        app.game.money -= app.game.seeds[name]['cost']
        app.game.inventory[name] = app.game.inventory.get(name,0) + 1
        fs = app.sm.get_screen('farm')
        fs.selected = name
        app.game.save()
        fs.update_ui()
        self.manager.current = 'farm'

class GearShopScreen(Screen): def on_enter(self): grid = self.ids.gear_grid grid.clear_widgets() app = App.get_running_app() for name,spec in app.game.gear.items(): btn = Button(text=f"{spec['label']} - Cost: ${spec['cost']}", size_hint_y=None, height=dp(40)) btn.bind(on_release=lambda btn,n=name: self.buy(n)) grid.add_widget(btn)

def buy(self,name):
    app = App.get_running_app()
    if app.game.money >= app.game.gear[name]['cost']:
        app.game.money -= app.game.gear[name]['cost']
        app.game.inventory[name] = app.game.inventory.get(name,0) + 1
        app.game.save()
        self.manager.current = 'farm'

class GameData: def init(self): self.store = JsonStore('mobile_store.json') if self.store.exists('data'): d = self.store.get('data') self.money = d.get('money',100) self.inventory = d.get('inventory',{}) else: self.money = 100 self.inventory = {} self.seeds = get_seeds() self.gear = get_gear()

def save(self):
    self.store.put('data', money=self.money, inventory=self.inventory)

class MobileApp(App): def build(self): self.sm = ScreenManager() Builder.load_string(KV) self.sm.add_widget(MenuScreen()) self.sm.add_widget(FarmScreen()) self.sm.add_widget(SeedShopScreen()) self.sm.add_widget(GearShopScreen()) self.game = GameData() return self.sm

def on_stop(self):
    self.game.save()

if name == 'main': MobileApp().run()

