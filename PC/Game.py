import pygame
import sys
import time
from settings import *
from general import draw_grid, show_loading_screen, draw_shop
from player import Player

class Tile:
    def __init__(self, x, y):
        self.rect = pygame.Rect(x, y, TILE_SIZE, TILE_SIZE)
        self.state = EMPTY
        self.watered = False
        self.plant_time = None

    def plant_seed(self):
        if self.state == EMPTY:
            self.state = SEED
            self.plant_time = time.time()
            self.watered = False

    def water(self):
        if self.state != EMPTY:
            self.watered = True

    def fertilize(self):
        if self.state in (SEED, SPROUT, PLANT):
            self.plant_time -= 2  # Fertilizer speeds up growth

    def update(self):
        if self.state in (SEED, SPROUT, PLANT) and self.watered:
            elapsed = time.time() - self.plant_time
            if self.state == SEED and elapsed > PLANT_GROWTH_TIME[1]:
                self.state = SPROUT
                self.plant_time = time.time()
                self.watered = False
            elif self.state == SPROUT and elapsed > PLANT_GROWTH_TIME[2]:
                self.state = PLANT
                self.plant_time = time.time()
                self.watered = False
            elif self.state == PLANT and elapsed > PLANT_GROWTH_TIME[3]:
                self.state = FLOWER
                self.watered = False

    def draw(self, surf):
        color = COLORS[self.state]
        if self.watered:
            color = COLORS["watered"]
        pygame.draw.rect(surf, color, self.rect)
        pygame.draw.rect(surf, (0,0,0), self.rect, 2)
        if self.state == FLOWER:
            pygame.draw.circle(surf, COLORS[FLOWER], self.rect.center, 20)

def open_shop(mx, my):
    return 600 <= mx <= 800 and 0 <= my <= 600

def buy_fertilizer(player):
    if player.spend_coins(5):
        player.add_item("fertilizer")
        return True
    return False

def earn_coins(player, amount):
    player.add_coins(amount)

def use_fertilizer(tile, player):
    if player.use_item("fertilizer"):
        tile.fertilize()

def draw_player_ui(screen, font, player):
    coins_text = font.render(f"Coins: {player.coins}", True, (0,0,0))
    screen.blit(coins_text, (10, 50))
    fert_text = font.render(f"Fertilizer: {player.inventory.get('fertilizer', 0)}", True, (0,0,0))
    screen.blit(fert_text, (10, 90))

def main():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("Grow A Garden")
    clock = pygame.time.Clock()
    font = pygame.font.SysFont(None, 36)

    show_loading_screen(screen, font, WIDTH, HEIGHT)
    tiles = [[Tile(x*TILE_SIZE+50, y*TILE_SIZE+50) for x in range(GRID_SIZE)] for y in range(GRID_SIZE)]
    selected_action = "plant"
    player = Player()

    while True:
        screen.fill((144, 238, 144))
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_SPACE:
                    selected_action = "water" if selected_action == "plant" else "plant"
            elif event.type == pygame.MOUSEBUTTONDOWN:
                mx, my = pygame.mouse.get_pos()
                if open_shop(mx, my):
                    buy_fertilizer(player)
                else:
                    for row in tiles:
                        for tile in row:
                            if tile.rect.collidepoint(mx, my):
                                if selected_action == "plant":
                                    tile.plant_seed()
                                elif selected_action == "water":
                                    tile.water()
                                elif selected_action == "fertilizer":
                                    use_fertilizer(tile, player)

        # Update and draw
        for row in tiles:
            for tile in row:
                tile.update()
        draw_grid(tiles, screen)
        draw_shop(screen, font, player)
        draw_player_ui(screen, font, player)

        # UI
        action_text = font.render(f"Action: {selected_action.title()} (Press SPACE to switch)", True, (0,0,0))
        screen.blit(action_text, (10, 10))

        pygame.display.flip()
        clock.tick(FPS)

if __name__ == "__main__":
    main()