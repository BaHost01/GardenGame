# Garden Tycoon Game in Python (using Pygame)

import pygame
import random
import time

# Init
pygame.init()
screen = pygame.display.set_mode((800, 600))
pygame.display.set_caption("Garden Tycoon V2")
clock = pygame.time.Clock()

# Colors
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
GREEN = (0, 200, 0)
BROWN = (139, 69, 19)

# Font
font = pygame.font.SysFont("Arial", 24)

# Global Game Data
player_money = 100
seeds = {
    "Carrot": {"price": 5, "growth": 30, "color": (255, 165, 0)},
    "Apple": {"price": 10, "growth": 60, "color": (255, 0, 0)},
    "Banana": {"price": 12, "growth": 70, "color": (255, 255, 0)},
    "Rare1": {"price": 0, "growth": 120, "color": (138, 43, 226), "rarity": "Event"},
    "SuperSeed": {"price": 0, "growth": 20, "color": (255, 105, 180), "rarity": "Robux"},
}
plots = []
selected_seed = None

# Plot class
class Plot:
    def __init__(self, x, y):
        self.rect = pygame.Rect(x, y, 60, 60)
        self.seed = None
        self.planted_time = None

    def draw(self):
        pygame.draw.rect(screen, BROWN, self.rect)
        if self.seed:
            growth = (time.time() - self.planted_time) / seeds[self.seed]["growth"]
            growth = min(growth, 1)
            color = seeds[self.seed]["color"]
            pygame.draw.rect(screen, color, self.rect.inflate(-20, -20 * (1 - growth)))

    def plant(self, seed_name):
        if self.seed is None:
            self.seed = seed_name
            self.planted_time = time.time()

# Draw UI
def draw_ui():
    money_text = font.render(f"Money: ${player_money}", True, WHITE)
    screen.blit(money_text, (10, 10))
    y = 50
    for name, data in seeds.items():
        btn = pygame.Rect(10, y, 150, 30)
        pygame.draw.rect(screen, GREEN if selected_seed == name else WHITE, btn)
        text = font.render(f"{name} (${data['price']})", True, BLACK)
        screen.blit(text, (15, y + 5))
        seed_buttons.append((btn, name))
        y += 40

# Game Setup
for i in range(5):
    for j in range(3):
        plots.append(Plot(200 + i * 70, 300 + j * 70))

# Game Loop
running = True
seed_buttons = []
while running:
    screen.fill((0, 100, 0))
    seed_buttons.clear()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

        elif event.type == pygame.MOUSEBUTTONDOWN:
            mx, my = event.pos
            for btn, name in seed_buttons:
                if btn.collidepoint(mx, my):
                    selected_seed = name
            for plot in plots:
                if plot.rect.collidepoint(mx, my):
                    if selected_seed and player_money >= seeds[selected_seed]["price"]:
                        plot.plant(selected_seed)
                        player_money -= seeds[selected_seed]["price"]

    draw_ui()
    for plot in plots:
        plot.draw()

    pygame.display.flip()
    clock.tick(30)

pygame.quit()
