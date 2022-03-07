from sanic import Sanic
from sanic.response import json

app = Sanic("Hello World, sanic app")

@app.route('/')
async def test(request):
    return json({'hello': 'world'})

if __name__ == '__main__':
    """
    python -m hello_world --host=127.0.0.1 --port=1337
    gunicorn hello_world_pkg:app --bind 127.0.0.1:1337 --worker-class sanic.worker.GunicornWorker
    gunicorn hello_world_pkg:app --bind 0.0.0.0:1337 --worker-class sanic.worker.GunicornWorker
    """
    # app.run()
    app.run(host="127.0.0.1", port=1234, debug=True)
    # app.run(host="0.0.0.0", port=1234, debug=True)