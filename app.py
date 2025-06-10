import pygame import sys import os import json import random import traceback from datetime import datetime

Inicializa o pygame

pygame.init()

Constantes de tela

WIDTH, HEIGHT = 800, 600 SCREEN = pygame.display.set_mode((WIDTH, HEIGHT)) pygame.display.set_caption("Gardening Game")

Cores

WHITE = (255, 255, 255) BLACK = (0, 0, 0) GREEN = (0, 255, 0) GRAY = (200, 200, 200)

Fontes

FONT = pygame.font.SysFont("arial", 20)

Caminhos

ASSET_PATH = "assets" SAVE_FILE = "save.json"

Dados do jogador

player_data = { "money": 100, "inventory": {}, "gears": [], "premium": False, }

Função para carregar imagens

def load_image(name): path = os.path.join(ASSET_PATH, name) try: image = pygame.image.load(path).convert_alpha() return image except pygame.error: print(f"Erro ao carregar imagem: {path}") return None

Plantas

plants = { "carrot": {"cost": 10, "growth_time": 5, "sell_price": 20}, "tomato": {"cost": 15, "growth_time": 7, "sell_price": 30}, "lettuce": {"cost": 5, "growth_time": 3, "sell_price": 10}, }

Salvar dados

def save_game(): with open(SAVE_FILE, "w") as f: json.dump(player_data, f)

Carregar dados

def load_game(): if os.path.exists(SAVE_FILE): with open(SAVE_FILE, "r") as f: data = json.load(f) player_data.update(data)

Plantação

class Plant: def init(self, type): self.type = type self.growth = 0 self.ready = False

def grow(self):
    self.growth += 1
    if self.growth >= plants[self.type]["growth_time"]:
        self.ready = True

def draw(self, surface, x, y):
    color = GREEN if self.ready else GRAY
    pygame.draw.rect(surface, color, (x, y, 40, 40))
    label = FONT.render(self.type[0].upper(), True, BLACK)
    surface.blit(label, (x + 10, y + 10))

Inicializar plantações

farm = [[None for _ in range(5)] for _ in range(3)]

Função para plantar

def plant_crop(row, col, crop): if player_data["money"] >= plants[crop]["cost"]: farm[row][col] = Plant(crop) player_data["money"] -= plants[crop]["cost"]

Função para colher

def harvest_crop(row, col): plant = farm[row][col] if plant and plant.ready: player_data["money"] += plants[plant.type]["sell_price"] farm[row][col] = None

Loop principal

def game_loop(): clock = pygame.time.Clock() load_game()

while True:
    SCREEN.fill(WHITE)

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            save_game()
            pygame.quit()
            sys.exit()
        elif event.type == pygame.MOUSEBUTTONDOWN:
            x, y = event.pos
            col = x // 50
            row = y // 50
            if row < 3 and col < 5:
                if farm[row][col] is None:
                    plant_crop(row, col, "carrot")
                else:
                    harvest_crop(row, col)

    # Atualizar crescimento
    for row in farm:
        for plant in row:
            if plant:
                plant.grow()

    # Desenhar plantações
    for i, row in enumerate(farm):
        for j, plant in enumerate(row):
            x, y = j * 50, i * 50
            pygame.draw.rect(SCREEN, BLACK, (x, y, 40, 40), 1)
            if plant:
                plant.draw(SCREEN, x, y)

    # Mostrar dinheiro
    money_label = FONT.render(f"Money: ${player_data['money']}", True, BLACK)
    SCREEN.blit(money_label, (600, 10))

    pygame.display.flip()
    clock.tick(60)

if name == "main": try: game_loop() except Exception as e: with open("error.log", "a") as f: f.write(f"{datetime.now()} - Erro: {str(e)}\n") traceback.print_exc()

