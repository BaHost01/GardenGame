class Player:
    def __init__(self):
        self.coins = 10
        self.inventory = {"fertilizer": 0}

    def add_coins(self, amount):
        self.coins += amount

    def spend_coins(self, amount):
        if self.coins >= amount:
            self.coins -= amount
            return True
        return False

    def add_item(self, item, amount=1):
        if item in self.inventory:
            self.inventory[item] += amount
        else:
            self.inventory[item] = amount

    def use_item(self, item):
        if self.inventory.get(item, 0) > 0:
            self.inventory[item] -= 1
            return True
        return False