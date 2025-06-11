import os import sys import time import json import logging from datetime import datetime import pygame from pygame.locals import *

BASE_DIR = os.path.dirname(os.path.abspath(file)) LOGS_DIR = os.path.join(BASE_DIR, 'logs') os.makedirs(LOGS_DIR, exist_ok=True) log_filename = os.path.join(LOGS_DIR, f"game_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt") logging.basicConfig( level=logging.DEBUG, format='%(asctime)s %(levelname)s:%(message)s', handlers=[ logging.FileHandler(log_filename, encoding='utf-8'), logging.StreamHandler(sys.stdout) ] )

CONFIG_PATH = os.path.join(BASE_DIR, 'config.json') default_config = { "WIDTH": 800, "HEIGHT": 600, "CELL_SIZE": 50, "GROW_TIME": 10.0, "WATER_BOOST": 0.5 }

if os.path.exists(CONFIG_PATH): try: with open(CONFIG_PATH, 'r', encoding='utf-8') as f: config = json.load(f) logging.info("Configuração carregada de config.json") except Exception: logging.exception("Falha ao ler config.json, usando valores padrão") config = default_config.copy() else: config = default_config.copy() with open(CONFIG_PATH, 'w', encoding='utf-8') as f: json.dump(config, f, indent=4) logging.info("config.json criado com valores padrão")

WIDTH = config.get('WIDTH', default_config['WIDTH']) HEIGHT = config.get('HEIGHT', default_config['HEIGHT']) CELL_SIZE = config.get('CELL_SIZE', default_config['CELL_SIZE']) GRID_COLS = WIDTH // CELL_SIZE GRID_ROWS = HEIGHT // CELL_SIZE GROW_TIME = config.get('GROW_TIME', default_config['GROW_TIME']) WATER_BOOST = config.get('WATER_BOOST', default_config['WATER_BOOST'])

WHITE = (255, 255, 255) GRAY = (200, 200, 200) GREEN = (34, 177, 76) DARK_GREEN = (0, 100, 0) BROWN = (139, 69, 19) BLUE = (0, 162, 232)

class Plant: def init(self, pos): self.pos = pos self.plant_time = time.time() self.watered_time = None logging.debug(f"Planta criada em {pos} às {self.plant_time}")

def growth_rate(self):
    return 1.0 + WATER_BOOST if self.watered_time else 1.0

def elapsed(self):
    now = time.time()
    total = (now - self.plant_time) * self.growth_rate()
    logging.debug(f"Crescimento em {self.pos}: elapsed={total:.2f}s, watered={self.watered_time is not None}")
    return total

def growth_stage(self):
    e = self.elapsed()
    if e < GROW_TIME * 0.3:
        return 1
    elif e < GROW_TIME * 0.7:
        return 2
    else:
        return 3

def is_mature(self):
    mature = self.growth_stage() == 3
    if mature:
        logging.debug(f"Planta em {self.pos} está madura")
    return mature

class Garden: def init(self): self.plants = {} self.score = 0

def plant_seed(self, cell):
    if cell not in self.plants:
        self.plants[cell] = Plant(cell)
        logging.info(f"Semente plantada em {cell}")

def water(self, cell):
    plant = self.plants.get(cell)
    if plant and not plant.is_mature():
        plant.watered_time = time.time()
        logging.info(f"Planta em {cell} regada às {plant.watered_time}")

def harvest(self, cell):
    plant = self.plants.get(cell)
    if plant and plant.is_mature():
        del self.plants[cell]
        self.score += 1
        logging.info(f"Planta em {cell} colhida. Pontos: {self.score}")

def draw(self, screen):
    for col in range(GRID_COLS):
        for row in range(GRID_ROWS):
            rect = pygame.Rect(col*CELL_SIZE, row*CELL_SIZE, CELL_SIZE-1, CELL_SIZE-1)
            pygame.draw.rect(screen, BROWN, rect)
    for plant in list(self.plants.values()):
        col, row = plant.pos
        rect = pygame.Rect(col*CELL_SIZE+5, row*CELL_SIZE+5, CELL_SIZE-10, CELL_SIZE-10)
        color = {1: DARK_GREEN, 2: GREEN, 3: BLUE}[plant.growth_stage()]
        pygame.draw.ellipse(screen, color, rect)

def display_score(self, screen, font):
    text = font.render(f"Colhidas: {self.score}", True, WHITE)
    screen.blit(text, (10, 10))

def save_config(): try: with open(CONFIG_PATH, 'w', encoding='utf-8') as f: json.dump(config, f, indent=4) logging.info("Configuração salva em config.json") except Exception: logging.exception("Falha ao salvar config.json")

def main(): try: pygame.init() screen = pygame.display.set_mode((WIDTH, HEIGHT)) pygame.display.set_caption("Gardening Game") clock = pygame.time.Clock() font = pygame.font.SysFont(None, 24) garden = Garden()

while True:
        for event in pygame.event.get():
            if event.type == QUIT:
                raise KeyboardInterrupt
            elif event.type == MOUSEBUTTONDOWN:
                cell = (event.pos[0] // CELL_SIZE, event.pos[1] // CELL_SIZE)
                if event.button == 1:
                    if cell in garden.plants and garden.plants[cell].is_mature():
                        garden.harvest(cell)
                    else:
                        garden.plant_seed(cell)
                elif event.button == 3:
                    garden.water(cell)

        screen.fill(GRAY)
        garden.draw(screen)
        garden.display_score(screen, font)
        pygame.display.update()
        clock.tick(30)
except KeyboardInterrupt:
    logging.info("Saindo do jogo")
except Exception:
    logging.exception("Erro inesperado no jogo")
finally:
    save_config()
    pygame.quit()

if name == 'main': main()

