from dataclasses import dataclass, asdict
import mysql.connector
import json


@dataclass
class InventoryItem:
    id: str
    inventory_id: str
    year: str
    make: str
    model: str
    vin: str
    color: str
    mileage: str
    description: str
    price: str
    status: str
    thumbnail: str
    path: str

    @property
    def __dict__(self):
        return asdict(self)

    @property
    def json(self):
        return json.dumps(self.__dict__)


dataBase = mysql.connector.connect(
    host="192.168.1.226",
    port=3308,
    user="root",
    passwd="password",
    database="atacar_temp",
)

cursorObject = dataBase.cursor()
query = "SELECT * from ata_cars where status in ('available', 'sold')"
cursorObject.execute(query)
items = cursorObject.fetchall()
dataBase.close()

output = "["
for i in items:
    output = output + InventoryItem(*i).json + ","
output = output + "]"

print(output)
