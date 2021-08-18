import socket
import os

#----- Info and inputs
# For helpful docker commands see:
# http://ropenscilabs.github.io/r-docker-tutorial/

# Edit as needed
docker_img = "ggir:r-4.1.0"
env = "hba-actig"
# -----


def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP


IP = get_ip()
local_dir = os.getcwd()

print(f"""
####################################################
 
 Running image {docker_img}...
 Paste the following address into the browser:
 http://{IP}:8787
 Username: {env}
 Password: {env}

####################################################
""")

# With password
docker_cmd = f"""docker run --rm \
    -v {local_dir}:/home/{env} \
    -w /home/{env} \
    -p 8787:8787 \
    -e USER={env} \
    -e PASSWORD={env} \
    -e ROOT=TRUE \
    {docker_img}"""

docker_run = os.system(docker_cmd)
