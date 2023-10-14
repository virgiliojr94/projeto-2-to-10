# Importar o FastAPI e o Pydantic
from fastapi import FastAPI, Query, Path, Body
from pydantic import BaseModel

# Criar uma instância do FastAPI
app = FastAPI()

# Criar um modelo Pydantic para a entidade Item
class Item(BaseModel):
    id: int
    name: str
    price: float
    description: str = None

# Criar uma lista de itens como um banco de dados falso
items = [
    Item(id=1, name="Lápis", price=0.5, description="Um lápis simples"),
    Item(id=2, name="Caneta", price=1.0, description="Uma caneta azul"),
    Item(id=3, name="Caderno", price=5.0, description="Um caderno de 100 páginas")
]

# Criar uma rota para obter todos os itens
@app.get("/items")
def get_items():
    return items

# Criar uma rota para obter um item pelo id
@app.get("/items/{item_id}")
def get_item(item_id: int = Path(..., ge=1)):
    for item in items:
        if item.id == item_id:
            return item
    return {"error": "Item não encontrado"}

# Criar uma rota para criar um novo item
@app.post("/items")
def create_item(item: Item = Body(...)):
    items.append(item)
    return {"message": "Item criado com sucesso"}

# Criar uma rota para atualizar um item pelo id
@app.put("/items/{item_id}")
def update_item(item_id: int = Path(..., ge=1), item: Item = Body(...)):
    for index, old_item in enumerate(items):
        if old_item.id == item_id:
            items[index] = item
            return {"message": "Item atualizado com sucesso"}
    return {"error": "Item não encontrado"}

# Criar uma rota para deletar um item pelo id
@app.delete("/items/{item_id}")
def delete_item(item_id: int = Path(..., ge=1)):
    for index, old_item in enumerate(items):
        if old_item.id == item_id:
            del items[index]
            return {"message": "Item deletado com sucesso"}
    return {"error": "Item não encontrado"}
