from flask import Flask, jsonify
from datetime import datetime, timedelta
import requests

app = Flask(__name__)

# openSenseMap API base URL
OSM_API_URL = "https://api.opensensemap.org"

# Specific senseBox ID
BOX_ID = "5eba5fbad46fb8001b799786"


@app.route("/")
def home():
    return jsonify({"message": "Welcome to HiveBox API"})


@app.route("/version", methods=["GET"])
def version():
    """
    Returns the version of the deployed app.
    Endpoint: /version
    Parameters: None
    """
    return jsonify({"version": "1.0.0"})


@app.route("/temperature", methods=["GET"])
def temperature():
    """
    Returns the current temperature from senseBox ID 5eba5fbad46fb8001b799786.
    Data must be no older than 1 hour.
    Endpoint: /temperature
    Parameters: None
    """
    try:
        # Calculate the time threshold (1 hour ago)
        one_hour_ago = datetime.utcnow() - timedelta(hours=1)

        # Fetch specific senseBox from openSenseMap
        response = requests.get(f"{OSM_API_URL}/boxes/{BOX_ID}")
        response.raise_for_status()  # Raise exception for bad status codes
        box = response.json()

        # Get sensors for the box
        sensors = box.get("sensors", [])
        for sensor in sensors:
            # Check if sensor measures temperature
            if sensor.get("title").lower() == "temperature" and sensor.get(
                "lastMeasurement"
            ):
                last_measurement = sensor["lastMeasurement"]
                measurement_time = datetime.strptime(
                    last_measurement["createdAt"], "%Y-%m-%dT%H:%M:%S.%fZ"
                )
                # Ensure measurement is within the last hour
                if measurement_time >= one_hour_ago:
                    try:
                        value = float(last_measurement["value"])
                        return jsonify({"temperature": round(value, 2)})
                    except (ValueError, TypeError):
                        continue  # Skip invalid values

        return jsonify(
            {
                "error": "No valid temperature data found within the last hour for this senseBox"
            }
        ), 404

    except requests.RequestException as e:
        return jsonify(
            {"error": f"Failed to fetch data from openSenseMap: {str(e)}"}
        ), 500
    except Exception as e:
        return jsonify({"error": f"An unexpected error occurred: {str(e)}"}), 500


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
