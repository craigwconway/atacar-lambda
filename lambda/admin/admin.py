import os
import json
from textwrap import indent
import boto3

from jinja2 import Template

from models import Item
from utils import read_local, write_local, read_s3, write_s3


ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD")
WEBSITE_BUCKET = os.getenv("WEBSITE_BUCKET")
DATA_BUCKET = os.getenv("DATA_BUCKET")


def get_item(id: int, items: list):
    for item in items:
        if id == item.id:
            return item
    return None


def next_id(items: list):
    top = 0
    for item in items:
        top = item.id if item.id > top else top
    return top + 1


def transform(items: list, t_list: str, t_item: str, event: dict):
    cmd = event["cmd"]
    if "create" == cmd:
        event["id"] = next_id(items)
        items = [Item.from_dict(event)] + items
    elif "update" == cmd:
        updated = Item.from_dict(event)
        for i, item in enumerate(items):
            if updated.id == item.id:
                items[i] = updated
                break
    elif "delete" == cmd:
        for i, item in enumerate(items):
            if item.id == int(event["id"]):
                del items[i]
                break
    outputs = [
        (
            "index.html",
            Template(t_list).render(
                items=[item.to_dict() for item in items if item.status == "available"]
            ),
        ),
        (
            "sold.html",
            Template(t_list).render(
                items=[item.to_dict() for item in items if item.status == "sold"]
            ),
        ),
    ]
    for item in items:
        if item.status in ("available", "sold"):
            outputs.append(
                (
                    f"inventory/item-{item.id}.html",
                    Template(t_item).render(item=get_item(item.id, items).to_dict()),
                )
            )

    return (items, outputs)


def local_handler(event):
    items = [
        Item.from_dict(item) for item in json.loads(read_local("../../data/data.json"))
    ]
    t_list = read_local("../../templates/list.html")
    t_item = read_local("../../templates/item.html")
    data = json.dumps([item.to_dict() for item in items])
    if event["cmd"] != "login":
        (items, outputs) = transform(items, t_list, t_item, event)
        data = json.dumps([item.to_dict() for item in items])
        write_local("../../data/data.json", data)
        for i in outputs:
            write_local(f"../../static/{i[0]}", i[1])


if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        event = {"cmd": "", "pw": ""}
        if "login" == cmd:
            event = json.loads(read_local("../../test/event/login.json"))
        elif "create" == cmd:
            event = json.loads(read_local("../../test/event/create.json"))
        elif "update" == cmd:
            event = json.loads(read_local("../../test/event/update.json"))
        elif "delete" == cmd:
            event = json.loads(read_local("../../test/event/delete.json"))
        elif "generate" == cmd:
            pass  # default action is generate templates
        local_handler(event)
        print("Done")
    else:
        print("Missing arg! Add one: login, create, update, delete, generate")


def lambda_handler(event, context):
    if (
        "requestContext" in event.keys()
        and "GET" == event["requestContext"]["http"]["method"]
    ):
        body = """
            <html><body style="background-color: black; color: red;">
                <form method="post">
                <input type="password" name="pw">
                <input type="hidden" name="cmd" value="login">
                <input type="submit">
                </form>
            </body></html>
        """
    elif "body" in event.keys():
        import base64
        from urllib import parse

        event = dict(parse.parse_qsl(base64.b64decode(event["body"]).decode()))

    if "pw" in event.keys() and event["pw"] == ADMIN_PASSWORD:
        s3_client = boto3.client("s3")
        s3_resource = boto3.resource("s3")
        items = [
            Item.from_dict(item)
            for item in json.loads(read_s3(s3_client, DATA_BUCKET, "data/data.json"))
        ]
        t_list = read_s3(s3_client, DATA_BUCKET, "templates/list.html")
        t_item = read_s3(s3_client, DATA_BUCKET, "templates/item.html")
        t_admin = read_s3(s3_client, DATA_BUCKET, "templates/admin.html")
        data = json.dumps([item.to_dict() for item in items])
        if event["cmd"] in ("create", "update", "delete"):
            (items, outputs) = transform(items, t_list, t_item, event)
            data = json.dumps([item.to_dict() for item in items])
            write_s3(s3_resource, DATA_BUCKET, "data/data.json", data)
            for i in outputs:
                write_s3(s3_resource, WEBSITE_BUCKET, i[0], i[1])
        body = Template(t_admin).render(
            items=[item.to_dict() for item in items],
            data=data,
            pw=event["pw"],
            msg=f"Completed {event['cmd']}",
        )

    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "headers": {"content-type": "text/html"},
        "body": f"{body}",
    }
