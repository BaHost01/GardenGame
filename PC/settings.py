WIDTH, HEIGHT = 1200, 800
GRID_SIZE = 10
TILE_SIZE = 100
FPS = 120

# Plant states
EMPTY, SEED, SPROUT, PLANT, FLOWER = 0, 1, 2, 3, 4
PLANT_GROWTH_TIME = [0, 3, 5, 7]  # seconds to next stage

COLORS = {
    EMPTY: (139, 69, 19),
    SEED: (205, 133, 63),
    SPROUT: (34, 139, 34),
    PLANT: (0, 128, 0),
    FLOWER: (255, 192, 203),
    "watered": (173, 216, 230)
}