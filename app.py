import os
import sys
import time
import json
import logging
from datetime import datetime

import pygame
from pygame.locals import *

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LOGS_DIR = os.path.join(BASE_DIR, 'logs')
os.makedirs(LOGS_DIR, exist_ok=True)
LOG_FILE = os.path.join(
    LOGS_DIR,
    f"game_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
)

logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s %(levelname)s:%(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE, encoding='utf-8'),
        logging.StreamHandler(sys.stdout),
    ]
)

CONFIG_PATH = os.path.join(BASE_DIR, 'config.json')
DEFAULT_CONFIG = {
    "WIDTH": 800,
    "HEIGHT": 600,
    "CELL_SIZE": 50,
    "GROW_TIME": 10.0,
    "WATER_BOOST": 0.5
}

if os.path.exists(CONFIG_PATH):
    try:
        with open(CONFIG_PATH, 'r', encoding='utf-8') as f:
            config = json.load(f)
        logging.info("Loaded config.json")
    except Exception:
        logging.exception("Failed to read config.json, using defaults")
        config = DEFAULT_CONFIG.copy()
else:
    config = DEFAULT_CONFIG.copy()
    with open(CONFIG_PATH, 'w', encoding='utf-8') as f:
        json.dump(config, f, indent=4)
    logging.info("Created config.json with default values")

WIDTH = config.get('WIDTH', DEFAULT_CONFIG['WIDTH'])
HEIGHT = config.get('HEIGHT', DEFAULT_CONFIG['HEIGHT'])
CELL_SIZE = config.get('CELL_SIZE', DEFAULT_CONFIG['CELL_SIZE'])
GRID_COLS = WIDTH // CELL_SIZE
GRID_ROWS = HEIGHT // CELL_SIZE
GROW_TIME = config.get('GROW_TIME', DEFAULT_CONFIG['GROW_TIME'])
WATER_BOOST = config.get('WATER_BOOST', DEFAULT_CONFIG['WATER_BOOST'])

WHITE = (255, 255, 255)
GRAY = (200, 200, 200)
GREEN = (34, 177, 76)
DARK_GREEN = (0, 100, 0)
BROWN = (139, 69, 19)
BLUE = (0, 162, 232)

class Plant:
    def __init__(self, pos):
        self.pos = pos
        self.plant_time = time.time()
        self.watered_time = None
        logging.debug(f"Plant created at {pos} (time={self.plant_time})")

    def growth_rate(self):
        return 1.0 + WATER_BOOST if self.watered_time else 1.0

    def elapsed(self):
        return (time.time() - self.plant_time) * self.growth_rate()

    def growth_stage(self):
        e = self.elapsed()
        if e < GROW_TIME * 0.3:
            return 1
        elif e < GROW_TIME * 0.7:
            return 2
        return 3

    def is_mature(self):
        return self.growth_stage() == 3

class Garden:
    def __init__(self):
        self.plants = {}
        self.score = 0

    def plant_seed(self, cell):
        if cell not in self.plants:
            self.plants[cell] = Plant(cell)
            logging.info(f"Planted seed at {cell}")

    def water(self, cell):
        plant = self.plants.get(cell)
        if plant and not plant.is_mature():
            plant.watered_time = time.time()
            logging.info(f"Watered plant at {cell} (time={plant.watered_time})")

    def harvest(self, cell):
        plant = self.plants.get(cell)
        if plant and plant.is_mature():
            del self.plants[cell]
            self.score += 1
            logging.info(f"Harvested plant at {cell}. Score={self.score}")

    def draw(self, screen):
        for col in range(GRID_COLS):
            for row in range(GRID_ROWS):
                rect = pygame.Rect(
                    col * CELL_SIZE,
                    row * CELL_SIZE,
                    CELL_SIZE - 1,
                    CELL_SIZE - 1
                )
                pygame.draw.rect(screen, BROWN, rect)

        for plant in self.plants.values():
            col, row = plant.pos
            rect = pygame.Rect(
                col * CELL_SIZE + 5,
                row * CELL_SIZE + 5,
                CELL_SIZE - 10,
                CELL_SIZE - 10
            )
            stage = plant.growth_stage()
            color = DARK_GREEN if stage == 1 else GREEN if stage == 2 else BLUE
            pygame.draw.ellipse(screen, color, rect)

    def display_score(self, screen, font):
        text = font.render(f"Harvested: {self.score}", True, WHITE)
        screen.blit(text, (10, 10))

def save_config():
    try:
        with open(CONFIG_PATH, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=4)
        logging.info("Saved config.json")
    except Exception:
        logging.exception("Failed to save config.json")

def main():
    try:
        pygame.init()
        screen = pygame.display.set_mode((WIDTH, HEIGHT))
        pygame.display.set_caption("Gardening Game")
        clock = pygame.time.Clock()
        font = pygame.font.SysFont(None, 24)
        garden = Garden()

        running = True
        while running:
            for event in pygame.event.get():
                if event.type == QUIT:
                    running = False
                elif event.type == MOUSEBUTTONDOWN:
                    x, y = event.pos
                    cell = (x // CELL_SIZE, y // CELL_SIZE)
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
            pygame.display.flip()
            clock.tick(30)

    except Exception:
        logging.exception("Unexpected error in game")
    finally:
        save_config()
        pygame.quit()
        sys.exit()

if __name__ == '__main__':
    main()
