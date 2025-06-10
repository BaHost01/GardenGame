import pygame
import sys
import math
import random
from enum import Enum

# Initialize pygame
pygame.init()

# Screen dimensions
SCREEN_WIDTH = 1000
SCREEN_HEIGHT = 700
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Bloom & Grow - Gardening Simulator")

# Colors with enhanced contrast
SKY_BLUE = (135, 206, 250)
GRASS_GREEN = (76, 153, 0)
GRID_LIGHT = (120, 180, 80)
GRID_DARK = (90, 140, 60)
GRID_HIGHLIGHT = (140, 200, 100)
SOIL_LIGHT = (180, 130, 80)
SOIL_DARK = (140, 90, 40)
SOIL_DRY = (170, 130, 70)
SOIL_WET = (130, 90, 50)
PLANT_GREEN = (40, 120, 60)
PLANT_DARK_GREEN = (20, 90, 40)
TEXT_LIGHT = (245, 245, 220)
TEXT_DARK = (50, 50, 40)
PANEL_BG = (30, 80, 40, 200)
BUTTON_LIGHT = (100, 180, 100)
BUTTON_DARK = (70, 140, 70)
BUTTON_HOVER = (120, 200, 120)
SUN_COLOR = (255, 230, 100)
CLOUD_COLOR = (245, 245, 255)
MONEY_COLOR = (255, 215, 50)
WATER_COLOR = (70, 170, 230)
UI_BG = (30, 60, 30)
UI_HIGHLIGHT = (60, 110, 60)
UI_SHADOW = (10, 40, 10)

# Fonts
font_small = pygame.font.SysFont('Arial', 16)
font_medium = pygame.font.SysFont('Arial', 24)
font_large = pygame.font.SysFont('Arial', 36, bold=True)
font_title = pygame.font.SysFont('Arial', 48, bold=True)

# Plant types
class PlantType(Enum):
    EMPTY = 0
    CARROT = 1
    TOMATO = 2
    SUNFLOWER = 3
    ROSE = 4
    CACTUS = 5
    APPLE_TREE = 6

# Plant information
plant_names = {
    PlantType.CARROT: "Carrot",
    PlantType.TOMATO: "Tomato",
    PlantType.SUNFLOWER: "Sunflower",
    PlantType.ROSE: "Rose",
    PlantType.CACTUS: "Cactus",
    PlantType.APPLE_TREE: "Apple Tree"
}

plant_prices = {
    PlantType.CARROT: 10,
    PlantType.TOMATO: 15,
    PlantType.SUNFLOWER: 20,
    PlantType.ROSE: 30,
    PlantType.CACTUS: 25,
    PlantType.APPLE_TREE: 50
}

plant_sell_prices = {
    PlantType.CARROT: 15,
    PlantType.TOMATO: 25,
    PlantType.SUNFLOWER: 35,
    PlantType.ROSE: 50,
    PlantType.CACTUS: 40,
    PlantType.APPLE_TREE: 80
}

plant_colors = {
    PlantType.CARROT: (255, 140, 0),
    PlantType.TOMATO: (220, 20, 60),
    PlantType.SUNFLOWER: (255, 200, 0),
    PlantType.ROSE: (220, 20, 60),
    PlantType.CACTUS: (80, 160, 80),
    PlantType.APPLE_TREE: (200, 30, 30)
}

# Plant growth stages
class GrowthStage(Enum):
    SEED = 0
    SPROUT = 1
    GROWING = 2
    MATURE = 3
    FLOWERING = 4
    READY = 5

# Plant class with enhanced visuals
class Plant:
    def __init__(self, plant_type):
        self.plant_type = plant_type
        self.growth_stage = GrowthStage.SEED
        self.growth_progress = 0
        self.water_level = 50
        self.max_growth = 100
        self.growth_rate = random.uniform(0.1, 0.3)
        self.water_consumption = random.uniform(0.05, 0.1)
        self.last_update = pygame.time.get_ticks()
        self.watered = False
        
    def update(self, current_time, weather_factor):
        # Update growth
        time_diff = (current_time - self.last_update) / 1000.0
        self.last_update = current_time
        
        # Apply growth based on water and weather
        if self.water_level > 0:
            growth = self.growth_rate * time_diff * weather_factor
            self.growth_progress += growth
            self.water_level -= self.water_consumption * time_diff
        
        # Update growth stage
        if self.growth_progress < 20:
            self.growth_stage = GrowthStage.SEED
        elif self.growth_progress < 40:
            self.growth_stage = GrowthStage.SPROUT
        elif self.growth_progress < 60:
            self.growth_stage = GrowthStage.GROWING
        elif self.growth_progress < 80:
            self.growth_stage = GrowthStage.MATURE
        elif self.growth_progress < 100:
            self.growth_stage = GrowthStage.FLOWERING
        else:
            self.growth_stage = GrowthStage.READY
    
    def water(self):
        self.water_level = min(100, self.water_level + 30)
        self.watered = True
    
    def draw(self, x, y, size):
        # Draw soil with gradient for depth
        soil_color = SOIL_WET if self.watered else SOIL_DRY
        pygame.draw.rect(screen, soil_color, (x, y, size, size))
        
        # Add soil texture
        for _ in range(10):
            tx = x + random.randint(0, size-1)
            ty = y + random.randint(0, size-1)
            pygame.draw.circle(screen, SOIL_LIGHT if self.watered else SOIL_DARK, (tx, ty), 1)
        
        # Draw plant based on type and growth stage
        center_x, center_y = x + size//2, y + size//2
        
        if self.plant_type == PlantType.CARROT:
            self.draw_carrot(center_x, center_y)
        elif self.plant_type == PlantType.TOMATO:
            self.draw_tomato(center_x, center_y)
        elif self.plant_type == PlantType.SUNFLOWER:
            self.draw_sunflower(center_x, center_y)
        elif self.plant_type == PlantType.ROSE:
            self.draw_rose(center_x, center_y)
        elif self.plant_type == PlantType.CACTUS:
            self.draw_cactus(center_x, center_y)
        elif self.plant_type == PlantType.APPLE_TREE:
            self.draw_apple_tree(center_x, center_y)
        
        # Reset watered state
        self.watered = False
    
    def draw_carrot(self, x, y):
        # Draw leaves
        if self.growth_stage.value >= GrowthStage.SPROUT.value:
            height = 5 + int(self.growth_progress / 2)
            for i in range(3):
                angle = i * 120
                leaf_x = x + int(math.cos(math.radians(angle)) * height/2)
                leaf_y = y - int(math.sin(math.radians(angle)) * height/2)
                
                # Draw leaf with gradient
                pygame.draw.line(screen, PLANT_GREEN, (x, y), (leaf_x, leaf_y), 3)
                pygame.draw.line(screen, PLANT_DARK_GREEN, (x, y), (leaf_x, leaf_y), 1)
        
        # Draw carrot
        if self.growth_stage.value >= GrowthStage.MATURE.value:
            carrot_height = 8 + int(self.growth_progress / 4)
            pygame.draw.ellipse(screen, plant_colors[self.plant_type], 
                               (x - 3, y + 2, 6, carrot_height))
            # Carrot shading
            pygame.draw.line(screen, (220, 120, 0), (x-2, y+2), (x-2, y+2+carrot_height), 1)
    
    def draw_tomato(self, x, y):
        # Draw stem
        if self.growth_stage.value >= GrowthStage.SPROUT.value:
            height = 5 + int(self.growth_progress / 2)
            pygame.draw.line(screen, PLANT_DARK_GREEN, (x, y), (x, y - height), 3)
            pygame.draw.line(screen, PLANT_GREEN, (x, y), (x, y - height), 1)
            
            # Draw branches
            if self.growth_stage.value >= GrowthStage.GROWING.value:
                for i in range(2):
                    angle = 30 + i * 120
                    branch_x = x + int(math.cos(math.radians(angle)) * height/2)
                    branch_y = y - height//2 - int(math.sin(math.radians(angle)) * height/2)
                    pygame.draw.line(screen, PLANT_DARK_GREEN, (x, y - height//2), (branch_x, branch_y), 2)
        
        # Draw tomatoes
        if self.growth_stage.value >= GrowthStage.MATURE.value:
            tomato_count = min(5, int((self.growth_progress - 60) / 8))
            for i in range(tomato_count):
                angle = i * 360/tomato_count
                tomato_x = x + int(math.cos(math.radians(angle)) * 15)
                tomato_y = y - height - int(math.sin(math.radians(angle)) * 10)
                
                # Tomato with shading
                pygame.draw.circle(screen, plant_colors[self.plant_type], (tomato_x, tomato_y), 5)
                pygame.draw.circle(screen, (190, 10, 50), (tomato_x-1, tomato_y-1), 5, 1)
                pygame.draw.circle(screen, (250, 100, 120), (tomato_x+1, tomato_y+1), 2)
    
    def draw_sunflower(self, x, y):
        # Draw stem
        stem_height = 10 + int(self.growth_progress / 1.5)
        if self.growth_stage.value >= GrowthStage.SPROUT.value:
            pygame.draw.line(screen, PLANT_DARK_GREEN, (x, y), (x, y - stem_height), 5)
            pygame.draw.line(screen, PLANT_GREEN, (x, y), (x, y - stem_height), 2)
            
        # Draw leaves
        if self.growth_stage.value >= GrowthStage.GROWING.value:
            leaf_size = 8 + int(self.growth_progress / 10)
            leaf_positions = [
                (x - 10, y - stem_height//2, -30),
                (x + 10, y - stem_height//2, 30)
            ]
            
            for lx, ly, angle in leaf_positions:
                pygame.draw.ellipse(screen, PLANT_GREEN, (lx - leaf_size//2, ly - leaf_size//4, leaf_size, leaf_size//2))
                pygame.draw.ellipse(screen, PLANT_DARK_GREEN, (lx - leaf_size//2, ly - leaf_size//4, leaf_size, leaf_size//2), 1)
            
        # Draw flower
        if self.growth_stage.value >= GrowthStage.FLOWERING.value:
            # Center
            pygame.draw.circle(screen, (100, 60, 0), (x, y - stem_height), 10)
            pygame.draw.circle(screen, (70, 40, 0), (x, y - stem_height), 10, 1)
            
            # Petals with shading
            for i in range(12):
                angle = i * 30
                petal_x = x + int(math.cos(math.radians(angle)) * 20)
                petal_y = y - stem_height + int(math.sin(math.radians(angle)) * 20
                
                # Draw petal with gradient
                pygame.draw.circle(screen, plant_colors[self.plant_type], (petal_x, petal_y), 8)
                pygame.draw.circle(screen, (230, 180, 0), (petal_x, petal_y), 8, 1)
    
    def draw_rose(self, x, y):
        # Draw stem
        stem_height = 8 + int(self.growth_progress / 2)
        if self.growth_stage.value >= GrowthStage.SPROUT.value:
            pygame.draw.line(screen, PLANT_DARK_GREEN, (x, y), (x, y - stem_height), 3)
            pygame.draw.line(screen, PLANT_GREEN, (x, y), (x, y - stem_height), 1)
            
            # Draw thorns
            if self.growth_stage.value >= GrowthStage.GROWING.value:
                for i in range(1, 3):
                    pygame.draw.line(screen, PLANT_DARK_GREEN, 
                                    (x, y - stem_height * i/3), 
                                    (x + 3, y - stem_height * i/3 + 3), 2)
        
        # Draw flower
        if self.growth_stage.value >= GrowthStage.FLOWERING.value:
            # Outer petals with shading
            for i in range(8):
                angle = i * 45
                petal_x = x + int(math.cos(math.radians(angle)) * 10
                petal_y = y - stem_height + int(math.sin(math.radians(angle)) * 10
                
                pygame.draw.circle(screen, plant_colors[self.plant_type], (petal_x, petal_y), 7)
                pygame.draw.circle(screen, (190, 10, 50), (petal_x, petal_y), 7, 1)
            
            # Inner petals
            for i in range(4):
                angle = i * 90 + 45
                petal_x = x + int(math.cos(math.radians(angle)) * 5
                petal_y = y - stem_height + int(math.sin(math.radians(angle)) * 5
                
                pygame.draw.circle(screen, (255, 100, 100), (petal_x, petal_y), 5)
                pygame.draw.circle(screen, (255, 150, 150), (petal_x, petal_y), 5, 1)
    
    def draw_cactus(self, x, y):
        # Draw main body with shading
        height = 15 + int(self.growth_progress / 1.5)
        width = 6 + int(self.growth_progress / 20)
        
        pygame.draw.ellipse(screen, plant_colors[self.plant_type], (x - width//2, y - height, width, height))
        pygame.draw.ellipse(screen, PLANT_DARK_GREEN, (x - width//2, y - height, width, height), 2)
        
        # Draw arms
        if self.growth_stage.value >= GrowthStage.MATURE.value:
            arm_y = y - height + 20
            pygame.draw.ellipse(screen, plant_colors[self.plant_type], (x - width//2 - 10, arm_y - 5, 10, 10))
            pygame.draw.ellipse(screen, plant_colors[self.plant_type], (x + width//2, arm_y, 10, 10))
            pygame.draw.ellipse(screen, PLANT_DARK_GREEN, (x - width//2 - 10, arm_y - 5, 10, 10), 1)
            pygame.draw.ellipse(screen, PLANT_DARK_GREEN, (x + width//2, arm_y, 10, 10), 1)
        
        # Draw spikes
        for i in range(0, height, 5):
            pygame.draw.line(screen, PLANT_DARK_GREEN, 
                            (x - width//2, y - height + i), 
                            (x - width//2 - 3, y - height + i), 1)
            pygame.draw.line(screen, PLANT_DARK_GREEN, 
                            (x + width//2, y - height + i), 
                            (x + width//2 + 3, y - height + i), 1)
        
        # Draw flower if ready
        if self.growth_stage == GrowthStage.READY:
            pygame.draw.circle(screen, (255, 150, 200), (x, y - height - 5), 5)
            pygame.draw.circle(screen, (255, 100, 180), (x, y - height - 5), 5, 1)
    
    def draw_apple_tree(self, x, y):
        # Draw trunk with shading
        trunk_width = 8 + int(self.growth_progress / 20)
        trunk_height = 25 + int(self.growth_progress / 1.2)
        
        pygame.draw.rect(screen, (120, 80, 40), (x - trunk_width//2, y - trunk_height, trunk_width, trunk_height))
        pygame.draw.rect(screen, (80, 50, 20), (x - trunk_width//2, y - trunk_height, trunk_width, trunk_height), 2)
        
        # Draw leaves with depth
        if self.growth_stage.value >= GrowthStage.SPROUT.value:
            leaf_size = 5 + int(self.growth_progress / 5)
            leaf_positions = [
                (x, y - trunk_height - leaf_size//2),  # Top
                (x - 15, y - trunk_height + 10),      # Left
                (x + 15, y - trunk_height + 10),      # Right
                (x - 10, y - trunk_height + 30),      # Bottom left
                (x + 10, y - trunk_height + 30)       # Bottom right
            ]
            
            for pos in leaf_positions:
                pygame.draw.circle(screen, PLANT_GREEN, pos, leaf_size)
                pygame.draw.circle(screen, PLANT_DARK_GREEN, pos, leaf_size, 1)
        
        # Draw apples with shading
        if self.growth_stage == GrowthStage.READY:
            apple_positions = [
                (x - 10, y - trunk_height),
                (x + 12, y - trunk_height + 15),
                (x - 15, y - trunk_height + 25),
                (x + 5, y - trunk_height + 35)
            ]
            
            for pos in apple_positions:
                pygame.draw.circle(screen, plant_colors[self.plant_type], pos, 5)
                pygame.draw.circle(screen, (150, 20, 20), pos, 5, 1)
                pygame.draw.circle(screen, (255, 150, 150), (pos[0]-1, pos[1]-1), 2)
                
                # Stem
                pygame.draw.line(screen, PLANT_DARK_GREEN, 
                                (pos[0], pos[1] - 5), 
                                (pos[0], pos[1] - 7), 1)

# Button class with enhanced visuals
class Button:
    def __init__(self, x, y, width, height, text, icon=None):
        self.rect = pygame.Rect(x, y, width, height)
        self.text = text
        self.hovered = False
        self.icon = icon
        self.border_radius = 10
        
    def draw(self, surface):
        # Button background with gradient
        if self.hovered:
            color_top = BUTTON_HOVER
            color_bottom = (90, 170, 90)
        else:
            color_top = BUTTON_LIGHT
            color_bottom = BUTTON_DARK
        
        # Draw button shadow
        shadow_rect = pygame.Rect(self.rect.x+3, self.rect.y+3, self.rect.width, self.rect.height)
        pygame.draw.rect(surface, UI_SHADOW, shadow_rect, border_radius=self.border_radius)
        
        # Draw button with gradient
        pygame.draw.rect(surface, color_bottom, self.rect, border_radius=self.border_radius)
        pygame.draw.rect(surface, color_top, 
                        pygame.Rect(self.rect.x, self.rect.y, self.rect.width, self.rect.height//2), 
                        border_radius=self.border_radius)
        
        # Draw border
        border_color = UI_HIGHLIGHT if self.hovered else (60, 100, 60)
        pygame.draw.rect(surface, border_color, self.rect, 2, border_radius=self.border_radius)
        
        # Draw text
        text_surf = font_medium.render(self.text, True, TEXT_DARK if self.hovered else TEXT_LIGHT)
        text_rect = text_surf.get_rect(center=self.rect.center)
        surface.blit(text_surf, text_rect)
        
    def check_hover(self, pos):
        self.hovered = self.rect.collidepoint(pos)
        return self.hovered
        
    def check_click(self, pos, event):
        if event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
            return self.rect.collidepoint(pos)
        return False

# Game class
class GardeningGame:
    def __init__(self):
        self.grid_size = 6
        self.cell_size = 80
        self.grid_offset_x = 50
        self.grid_offset_y = 120
        self.grid = [[PlantType.EMPTY] * self.grid_size for _ in range(self.grid_size)]
        self.plants = [[None] * self.grid_size for _ in range(self.grid_size)]
        self.selected_plant = PlantType.CARROT
        self.money = 100
        self.water_can = 100
        self.day = 1
        self.weather = "Sunny"
        self.weather_factor = 1.0
        self.clock = pygame.time.Clock()
        self.last_weather_change = pygame.time.get_ticks()
        self.game_speed = 1.0
        self.sun_position = 0
        self.cloud_position = 0
        
        # Create buttons
        button_width = 140
        button_height = 45
        button_spacing = 15
        self.buttons = []
        
        # Plant buttons
        for i, plant in enumerate([PlantType.CARROT, PlantType.TOMATO, PlantType.SUNFLOWER, 
                                  PlantType.ROSE, PlantType.CACTUS, PlantType.APPLE_TREE]):
            x = self.grid_offset_x + self.grid_size * self.cell_size + 50
            y = 180 + i * (button_height + button_spacing)
            self.buttons.append(Button(x, y, button_width, button_height, plant_names[plant]))
        
        # Action buttons
        self.buttons.append(Button(self.grid_offset_x + self.grid_size * self.cell_size + 50, 
                                  550, button_width, button_height, "Water All"))
        self.buttons.append(Button(self.grid_offset_x + self.grid_size * self.cell_size + 50, 
                                  610, button_width, button_height, "Harvest All"))
        
        # Game speed buttons
        self.buttons.append(Button(SCREEN_WIDTH - 180, 30, 50, 35, "1x"))
        self.buttons.append(Button(SCREEN_WIDTH - 120, 30, 50, 35, "2x"))
        self.buttons.append(Button(SCREEN_WIDTH - 60, 30, 50, 35, "5x"))
        
        # Seed bag icon
        self.seed_bag = pygame.Surface((40, 40), pygame.SRCALPHA)
        pygame.draw.rect(self.seed_bag, (200, 180, 140), (0, 0, 40, 40), border_radius=8)
        pygame.draw.rect(self.seed_bag, (150, 130, 90), (0, 0, 40, 40), 2, border_radius=8)
        for _ in range(20):
            x = random.randint(5, 35)
            y = random.randint(5, 35)
            pygame.draw.circle(self.seed_bag, (80, 50, 20), (x, y), 2)
    
    def handle_events(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            
            # Handle button clicks
            mouse_pos = pygame.mouse.get_pos()
            for i, button in enumerate(self.buttons):
                if button.check_click(mouse_pos, event):
                    if i < 6:  # Plant selection buttons
                        plant_type = list(plant_names.keys())[i]
                        if self.money >= plant_prices[plant_type]:
                            self.selected_plant = plant_type
                    elif i == 6:  # Water All
                        self.water_all_plants()
                    elif i == 7:  # Harvest All
                        self.harvest_all_plants()
                    elif i == 8:  # 1x speed
                        self.game_speed = 1.0
                    elif i == 9:  # 2x speed
                        self.game_speed = 2.0
                    elif i == 10:  # 5x speed
                        self.game_speed = 5.0
            
            # Handle grid clicks
            if event.type == pygame.MOUSEBUTTONDOWN:
                mouse_pos = pygame.mouse.get_pos()
                grid_x = (mouse_pos[0] - self.grid_offset_x) // self.cell_size
                grid_y = (mouse_pos[1] - self.grid_offset_y) // self.cell_size
                
                if 0 <= grid_x < self.grid_size and 0 <= grid_y < self.grid_size:
                    if event.button == 1:  # Left click - plant or water
                        if self.grid[grid_y][grid_x] == PlantType.EMPTY:
                            # Plant new plant
                            if self.money >= plant_prices[self.selected_plant]:
                                self.grid[grid_y][grid_x] = self.selected_plant
                                self.plants[grid_y][grid_x] = Plant(self.selected_plant)
                                self.money -= plant_prices[self.selected_plant]
                        else:
                            # Water existing plant
                            if self.water_can > 0:
                                self.plants[grid_y][grid_x].water()
                                self.water_can -= 10
                    elif event.button == 3:  # Right click - harvest
                        if self.grid[grid_y][grid_x] != PlantType.EMPTY:
                            plant = self.plants[grid_y][grid_x]
                            if plant.growth_stage == GrowthStage.READY:
                                self.money += plant_sell_prices[self.grid[grid_y][grid_x]]
                                self.grid[grid_y][grid_x] = PlantType.EMPTY
                                self.plants[grid_y][grid_x] = None
    
    def update(self):
        # Update weather
        current_time = pygame.time.get_ticks()
        if current_time - self.last_weather_change > 30000:  # Change every 30 seconds
            self.last_weather_change = current_time
            weather_options = ["Sunny", "Cloudy", "Rainy"]
            self.weather = random.choice(weather_options)
            
            if self.weather == "Sunny":
                self.weather_factor = 1.2
            elif self.weather == "Cloudy":
                self.weather_factor = 0.8
            else:  # Rainy
                self.weather_factor = 1.5
                # Refill water can when raining
                self.water_can = min(100, self.water_can + 30)
        
        # Update sun position
        self.sun_position = (self.sun_position + 0.2) % 360
        self.cloud_position = (self.cloud_position + 0.1) % 360
        
        # Update plants
        for y in range(self.grid_size):
            for x in range(self.grid_size):
                if self.grid[y][x] != PlantType.EMPTY:
                    self.plants[y][x].update(current_time, self.weather_factor)
    
    def water_all_plants(self):
        if self.water_can > 0:
            for y in range(self.grid_size):
                for x in range(self.grid_size):
                    if self.grid[y][x] != PlantType.EMPTY:
                        self.plants[y][x].water()
                        self.water_can -= 5
    
    def harvest_all_plants(self):
        for y in range(self.grid_size):
            for x in range(self.grid_size):
                if (self.grid[y][x] != PlantType.EMPTY and 
                    self.plants[y][x].growth_stage == GrowthStage.READY):
                    self.money += plant_sell_prices[self.grid[y][x]]
                    self.grid[y][x] = PlantType.EMPTY
                    self.plants[y][x] = None
    
    def draw(self):
        # Draw sky background with gradient
        for y in range(SCREEN_HEIGHT):
            # Calculate gradient from light blue at top to darker at bottom
            shade = max(0, min(255, int(135 - y * 0.05)))
            color = (shade, 206, 250)
            pygame.draw.line(screen, color, (0, y), (SCREEN_WIDTH, y))
        
        # Draw sun with animation
        sun_x = 100 + math.sin(math.radians(self.sun_position)) * 50
        sun_y = 80 + math.cos(math.radians(self.sun_position)) * 20
        pygame.draw.circle(screen, SUN_COLOR, (sun_x, sun_y), 40)
        pygame.draw.circle(screen, (255, 240, 150), (sun_x, sun_y), 40, 2)
        
        # Draw clouds with animation
        for i in range(3):
            cloud_x = 300 + i * 150 + math.sin(math.radians(self.cloud_position + i * 120)) * 30
            cloud_y = 70 + i * 40
            for j in range(4):
                pygame.draw.circle(screen, CLOUD_COLOR, (int(cloud_x + j * 25), int(cloud_y)), 20)
        
        # Draw title with shadow
        title = font_title.render("BLOOM & GROW", True, UI_SHADOW)
        screen.blit(title, (SCREEN_WIDTH//2 - title.get_width()//2 + 3, 23))
        title = font_title.render("BLOOM & GROW", True, TEXT_LIGHT)
        screen.blit(title, (SCREEN_WIDTH//2 - title.get_width()//2, 20))
        
        # Draw ground background
        pygame.draw.rect(screen, GRASS_GREEN, (0, self.grid_offset_y - 20, SCREEN_WIDTH, SCREEN_HEIGHT - self.grid_offset_y + 20))
        
        # Draw garden plot with depth
        plot_rect = pygame.Rect(
            self.grid_offset_x - 15, 
            self.grid_offset_y - 15,
            self.grid_size * self.cell_size + 30,
            self.grid_size * self.cell_size + 30
        )
        
        # Plot shadow
        pygame.draw.rect(screen, UI_SHADOW, 
                        (plot_rect.x + 5, plot_rect.y + 5, 
                         plot_rect.width, plot_rect.height),
                        border_radius=12)
        
        # Plot background
        pygame.draw.rect(screen, UI_BG, plot_rect, border_radius=10)
        pygame.draw.rect(screen, UI_HIGHLIGHT, plot_rect, 2, border_radius=10)
        
        # Draw grid
        for y in range(self.grid_size):
            for x in range(self.grid_size):
                rect_x = self.grid_offset_x + x * self.cell_size
                rect_y = self.grid_offset_y + y * self.cell_size
                
                # Draw grid cell with depth
                cell_rect = pygame.Rect(rect_x, rect_y, self.cell_size, self.cell_size)
                
                # Cell shadow
                pygame.draw.rect(screen, UI_SHADOW, 
                                (cell_rect.x + 2, cell_rect.y + 2, 
                                 cell_rect.width, cell_rect.height),
                                border_radius=5)
                
                # Cell background
                pygame.draw.rect(screen, GRID_DARK, cell_rect, border_radius=5)
                pygame.draw.rect(screen, GRID_LIGHT, 
                                (cell_rect.x, cell_rect.y, 
                                 cell_rect.width, cell_rect.height - 3),
                                border_radius=5)
                pygame.draw.rect(screen, GRID_LINES, cell_rect, 1, border_radius=5)
                
                # Draw plant if exists
                if self.grid[y][x] != PlantType.EMPTY:
                    self.plants[y][x].draw(rect_x, rect_y, self.cell_size)
        
        # Draw UI panel
        panel_width = 250
        panel_height = self.grid_size * self.cell_size + 30
        panel_rect = pygame.Rect(
            self.grid_offset_x + self.grid_size * self.cell_size + 20, 
            self.grid_offset_y - 15,
            panel_width,
            panel_height
        )
        
        # Panel shadow
        pygame.draw.rect(screen, UI_SHADOW, 
                        (panel_rect.x + 3, panel_rect.y + 3, 
                         panel_rect.width, panel_rect.height),
                        border_radius=12)
        
        # Panel background
        pygame.draw.rect(screen, PANEL_BG, panel_rect, border_radius=10)
        pygame.draw.rect(screen, UI_HIGHLIGHT, panel_rect, 2, border_radius=10)
        
        # Draw UI elements
        self.draw_ui()
        
        # Draw buttons
        mouse_pos = pygame.mouse.get_pos()
        for button in self.buttons:
            button.check_hover(mouse_pos)
            button.draw(screen)
        
        # Draw selected plant
        selected_text = font_medium.render(f"Selected:", True, TEXT_LIGHT)
        screen.blit(selected_text, (self.grid_offset_x + self.grid_size * self.cell_size + 50, 140))
        
        plant_name = font_medium.render(f"{plant_names[self.selected_plant]}", True, TEXT_LIGHT)
        screen.blit(plant_name, (self.grid_offset_x + self.grid_size * self.cell_size + 150, 140))
        
        # Draw seed bag icon
        screen.blit(self.seed_bag, (self.grid_offset_x + self.grid_size * self.cell_size + 55, 135))
        
        # Draw game speed
        speed_text = font_small.render(f"Speed: {self.game_speed}x", True, TEXT_LIGHT)
        screen.blit(speed_text, (SCREEN_WIDTH - 180, 70))
    
    def draw_ui(self):
        # Draw money panel
        money_panel = pygame.Rect(20, 20, 200, 50)
        pygame.draw.rect(screen, UI_SHADOW, (money_panel.x+3, money_panel.y+3, money_panel.width, money_panel.height), border_radius=8)
        pygame.draw.rect(screen, (50, 100, 50), money_panel, border_radius=8)
        pygame.draw.rect(screen, UI_HIGHLIGHT, money_panel, 2, border_radius=8)
        
        money_text = font_medium.render(f"Money: ${self.money}", True, MONEY_COLOR)
        screen.blit(money_text, (money_panel.x + 10, money_panel.y + 12))
        
        # Draw weather panel
        weather_panel = pygame.Rect(SCREEN_WIDTH - 250, 20, 220, 50)
        pygame.draw.rect(screen, UI_SHADOW, (weather_panel.x+3, weather_panel.y+3, weather_panel.width, weather_panel.height), border_radius=8)
        pygame.draw.rect(screen, (50, 100, 50), weather_panel, border_radius=8)
        pygame.draw.rect(screen, UI_HIGHLIGHT, weather_panel, 2, border_radius=8)
        
        weather_text = font_medium.render(f"Weather: {self.weather}", True, TEXT_LIGHT)
        screen.blit(weather_text, (weather_panel.x + 10, weather_panel.y + 12))
        
        # Draw water can
        water_panel = pygame.Rect(20, 80, 200, 30)
        pygame.draw.rect(screen, UI_SHADOW, (water_panel.x+3, water_panel.y+3, water_panel.width, water_panel.height), border_radius=5)
        pygame.draw.rect(screen, (30, 70, 120), water_panel, border_radius=5)
        
        # Water level
        water_level = pygame.Rect(water_panel.x+2, water_panel.y+2, self.water_can * 1.96, water_panel.height-4)
        pygame.draw.rect(screen, WATER_COLOR, water_level, border_radius=4)
        
        pygame.draw.rect(screen, UI_HIGHLIGHT, water_panel, 2, border_radius=5)
        water_text = font_small.render(f"Water: {int(self.water_can)}%", True, TEXT_LIGHT)
        screen.blit(water_text, (water_panel.x + 70, water_panel.y + 7))
        
        # Draw plant info panel
        info_panel = pygame.Rect(
            self.grid_offset_x, 
            self.grid_offset_y + self.grid_size * self.cell_size + 20,
            self.grid_size * self.cell_size,
            80
        )
        
        # Panel with depth
        pygame.draw.rect(screen, UI_SHADOW, 
                        (info_panel.x+3, info_panel.y+3, info_panel.width, info_panel.height),
                        border_radius=10)
        pygame.draw.rect(screen, (40, 90, 40), info_panel, border_radius=10)
        pygame.draw.rect(screen, UI_HIGHLIGHT, info_panel, 2, border_radius=10)
        
        info_title = font_medium.render("Gardener's Guide:", True, TEXT_LIGHT)
        screen.blit(info_title, (info_panel.x + 15, info_panel.y + 15))
        
        info_text = [
            "LEFT-CLICK: Plant/Water",
            "RIGHT-CLICK: Harvest",
            "RAIN: Refills water can",
            "SELL: When fully grown"
        ]
        
        for i, text in enumerate(info_text):
            text_surf = font_small.render(text, True, TEXT_LIGHT)
            screen.blit(text_surf, (info_panel.x + 15 + i*220, info_panel.y + 45))
    
    def run(self):
        while True:
            self.handle_events()
            self.update()
            self.draw()
            pygame.display.flip()
            self.clock.tick(60) * self.game_speed

# Start the game
if __name__ == "__main__":
    game = GardeningGame()
    game.run()
