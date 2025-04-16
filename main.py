from flask import Flask, jsonify
import requests

app = Flask(__name__)


@app.route("/version")
def version():
    return jsonify({"version": "1.0.0"})


@app.route("/temperature")
def temperature():
    try:
        box_id = "5eba5fbad46fb8001b799786"

        response = requests.get(f"https://api.opensensemap.org/boxes/{box_id}")
        box = response.json()

        for sensor in box["sensors"]:
            if sensor["title"] == "Temperatur" and "lastMeasurement" in sensor:
                return jsonify(
                    {"temperature": float(sensor["lastMeasurement"]["value"])}
                )

        return jsonify({"error": "Temperature data not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
