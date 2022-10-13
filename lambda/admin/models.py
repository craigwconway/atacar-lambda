from dataclasses import dataclass, asdict


@dataclass
class Item:
    id: int
    inventory_id: str
    year: str
    make: str
    model: str
    vin: str
    color: str
    mileage: str
    price: str
    status: str
    thumbnail: str
    path: str
    description: str

    def to_dict(self):
        return asdict(self)

    @classmethod
    def from_dict(self, item: dict):
        return Item(
            int(item.get("id")),
            item.get("inventory_id", ""),
            item.get("year", ""),
            item.get("make", ""),
            item.get("model", ""),
            item.get("vin", ""),
            item.get("color", ""),
            item.get("mileage", ""),
            item.get("price", ""),
            item.get("status", ""),
            item.get("thumbnail", ""),
            item.get("path", ""),
            item.get("description", ""),
        )
