import pygame
from settings import COLORS

def draw_grid(tiles, screen):
    for row in tiles:
        for tile in row:
            tile.draw(screen)

def show_loading_screen(screen, font, WIDTH, HEIGHT):
    screen.fill((255, 255, 255))
    loading_text = font.render("Loading Garden...", True, (0, 128, 0))
    screen.blit(loading_text, (WIDTH // 2 - loading_text.get_width() // 2, HEIGHT // 2 - loading_text.get_height() // 2))
    pygame.display.flip()
    pygame.time.delay(2000)

def draw_shop(screen, font, player):
    pygame.draw.rect(screen, (200, 200, 200), (600, 0, 200, 600))
    shop_title = font.render("Shop", True, (0, 0, 0))
    screen.blit(shop_title, (620, 20))
    fert_text = font.render("Fertilizer - 5 coins", True, (0, 0, 0))
    screen.blit(fert_text, (620, 70))
    inv_text = font.render(f"Your Fertilizer: {player.inventory.get('fertilizer', 0)}", True, (0, 0, 0))
    screen.blit(inv_text, (620, 120))
    coins_text = font.render(f"Coins: {player.coins}", True, (0, 0, 0))
    screen.blit(coins_text, (620, 170))