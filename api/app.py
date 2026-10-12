from flask import Flask, request, jsonify, render_template_string
import subprocess
import os

app = Flask(__name__)

# Flag 2: Web RCE / API Flag
API_FLAG = "YKOS{cmd_1nj3ct10n_t0_c0nt41n3r_sh3ll}"

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>YkOs Cloud DevOps & Diagnostic API</title>
    <style>
        body { font-family: 'Segoe UI', monospace; background: #0f172a; color: #e2e8f0; padding: 2rem; }
        .container { max-width: 700px; margin: 0 auto; background: #1e293b; padding: 2rem; border-radius: 8px; border: 1px solid #334155; }
        h2 { color: #38bdf8; }
        input[type="text"] { width: 70%; padding: 0.6rem; background: #0f172a; border: 1px solid #475569; color: #fff; border-radius: 4px; }
        button { padding: 0.6rem 1.2rem; background: #0284c7; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
        button:hover { background: #0369a1; }
        pre { background: #020617; padding: 1rem; border-radius: 6px; border: 1px solid #1e293b; overflow-x: auto; color: #4ade80; }
        .badge { background: #e11d48; color: white; padding: 2px 8px; border-radius: 4px; font-size: 0.8rem; }
    </style>
</head>
<body>
    <div class="container">
        <span class="badge">Modern DevOps Endpoint</span>
        <h2>YkOs Health Diagnostic & Ping Tool</h2>
        <p>Test network connectivity or query server status.</p>
        <form method="GET" action="/">
            <input type="text" name="host" placeholder="e.g. 127.0.0.1" value="{{ request.args.get('host', '127.0.0.1') }}">
            <button type="submit">Diagnose (Ping)</button>
        </form>
        {% if output %}
        <h3>Diagnostic Output:</h3>
        <pre>{{ output }}</pre>
        {% endif %}
        <hr style="border-color:#334155; margin: 2rem 0;">
        <small style="color:#94a3b8;">
            Hint: This microservice runs inside an isolated Docker container. 
            Inspect the Docker socket (/var/run/docker.sock) to escape to the host Linux operating system.
        </small>
    </div>
</body>
</html>
"""

@app.route('/', methods=['GET'])
def index():
    host = request.args.get('host')
    output = None
    if host:
        try:
            # Intentionally vulnerable Command Injection:
            cmd = f"ping -c 2 {host}"
            output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, text=True, timeout=5)
        except subprocess.CalledProcessError as e:
            output = e.output
        except Exception as e:
            output = str(e)
    return render_template_string(HTML_TEMPLATE, output=output)

@app.route('/api/flag', methods=['GET'])
def get_flag():
    return jsonify({"service": "YkOs Cloud DevOps API", "flag": API_FLAG})

if __name__ == '__main__':
    # Write breakout flag inside container root
    with open('/root/flag_docker.txt', 'w') as f:
        f.write("YKOS{d0ck3r_s0ck3t_3sc4p3_succ3ss}\n")
    app.run(host='0.0.0.0', port=5000)
