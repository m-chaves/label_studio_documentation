
# Hosting Label Studio on a Virtual Machine

**Author:** Mariana Chaves

**Last update** May 7th, 2025

- [Hosting Label Studio on a Virtual Machine](#hosting-label-studio-on-a-virtual-machine)
  - [Description](#description)
    - [This setup is ideal when:](#this-setup-is-ideal-when)
    - [This is an overkill when:](#this-is-an-overkill-when)
  - [Prerequisites](#prerequisites)
  - [1. Prepare the Virtual Machine](#1-prepare-the-virtual-machine)
  - [2. Install Label Studio](#2-install-label-studio)
  - [3. Set Up External Access](#3-set-up-external-access)
  - [4. Run Label Studio as a Background Process](#4-run-label-studio-as-a-background-process)
    - [For later: Other useful screen commands](#for-later-other-useful-screen-commands)
  - [5. Add Data to Label Studio](#5-add-data-to-label-studio)
    - [Method 1: Use the Label Studio port explicitly](#method-1-use-the-label-studio-port-explicitly)
    - [Method 2: Transfer Label Studio Projects to the VM](#method-2-transfer-label-studio-projects-to-the-vm)
  - [Apendix](#apendix)
    - [A. Rebooting the VM](#a-rebooting-the-vm)
    - [B. Editing the nginx configuration](#b-editing-the-nginx-configuration)
    - [C. Other useful nginx commands](#c-other-useful-nginx-commands)
    - [D. Scripts to transfer data between the VM and your local machine](#d-scripts-to-transfer-data-between-the-vm-and-your-local-machine)


## Description

[Label Studio](https://labelstud.io/) is an open-source data annotation tool that supports multiple data types.
In this guide, we will set up Label Studio on a **virtual machine (VM)**, making it accessible over the internet.
This set up allows **multiple users to access your Label Studio instance just by clicking a link**.

### This setup is ideal when:
- Multiple users need centralized access to Label Studio.
- You want to host Label Studio persistently (i.e., not on a local machine).
- You want your Label Studio instance to be accessible 24/7.
- You want your Label Studio instance to be accessible from any device with internet access.

### This is an overkill when:
- You are the only user and can run Label Studio locally.
- You are working on a small project, for instance, there are only a few annotators participating in your project. (In this case, you might what to take a look at [Label Studio and ngrok integration](ngrok_integration.md))

## Prerequisites

We assume that:

- You have a virtual machine (VM) set up with SSH access and an open port (e.g. `8080`) for web access. You know the hostname or alias of your VM (e.g. `example.i3s.unice.fr`). If you don't have a VM yet, you can get one from I3S.
- You are familiar with setting up a Label Studio project. If that is not the case, please refer to [this guide](setup.md) to get you started.

This guide is tailored for a VM with Linux environment, but the principles can be adapted for other systems.

## 1. Prepare the Virtual Machine

Open your terminal. Access your VM via SSH. For example:

```bash
ssh username@ip_address.i3s.unice.fr
```

Update the system

```bash
sudo apt update && sudo apt upgrade -y
```

Install Python, pip and venv :

```bash
sudo apt install python3 python3-pip python3.10-venv -y
```

> **Note:** Depending on the VM's Linux distribution, you might need to use ```dnf``` instead of ```apt``` in your commands.

Access your project directory. If you don't have a directory yet, create one:

```bash
mkdir <your_directory>
```

Then access it:

```bash
cd <your_directory>
```

## 2. Install Label Studio

Create and activate a virtual environment. For instance, we will create a virtual environment called `label-studio`:

```bash
python3 -m venv label-studio
source label-studio/bin/activate
```

Install Label Studio

```bash
pip install label-studio
```

## 3. Set Up External Access

Label Studio by default runs on port `8080`. You’ll want to make it accessible to users via the hostname (e.g. example.i3s.unice.fr.). We will use nginx for that.

Check that you have an open port

```bash
ss -tulnp
# or
netstat -tulnp
```

You should see a result like this:

```bash
Netid   State    Recv-Q   Send-Q      Local Address:Port       Peer Address:Port   Process

```bash
Netid   State    Recv-Q   Send-Q      Local Address:Port       Peer Address:Port   Process
udp     UNCONN   0        0           127.0.0.53%lo:53              0.0.0.0:*
tcp     LISTEN   0        128               0.0.0.0:22              0.0.0.0:*
tcp     LISTEN   0        511               0.0.0.0:80              0.0.0.0:*
```

All ports whose local address includes `0.0.0.0` are open to the internet. In this example, we can see that port `80` is open. In fact, port `80` is the default HTTP port. If none of the ports are open, you will need to open one. You can do this using the `ufw` commands or contacting your system administrator. In our case, we will use port `80`.

Install Nginx

```bash
sudo apt install nginx -y
```

Create a new Nginx configuration file

```bash
sudo nano /etc/nginx/sites-available/label-studio
```

In the text file that opens, paste a text like the one below.

You will need to adapt the `server_name` line to your own hostname. Remember this hostname is the link that will be shared with your users so they can access your Label Studio instance. You might also want to change the `listen` line to match the port that is open to the internet on your VM. In this example, we are using port `80`.

```nginx
server {
    listen 80;
    server_name example.i3s.unice.fr;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location ~ /api/projects/.*/export {
        deny all;
    }
}
```


Notice that the segment

```nginx
location ~ /api/projects/.*/export {

        deny all;

    }
```
is used to **disallow the export of annotations**. That is, the users that access the Label-Studio project cannot use the "download" buttom. This is a security feature that prevents users from downloading the data. If you want to allow users to download the data, you can remove this segment.

Save and exit usign `Ctrl + O`, `Enter`, `Ctrl + X`

Enable the new config

```bash
sudo ln -s /etc/nginx/sites-available/label-studio /etc/nginx/sites-enabled/
```

Test the new Nginx configuration for syntax errors

```bash
sudo nginx -t
```

Reload Nginx to apply the changes
```bash
sudo systemctl reload nginx
```

Open ports in the firewall (UFW)

```bash
sudo ufw status
sudo ufw allow 'Nginx Full'
sudo ufw reload
```

## 4. Run Label Studio as a Background Process

Use `screen` to keep Label Studio running 24/7 after closing the terminal.

Install screen

```bash
sudo apt install screen -y
```

Create a screen session

```bash
screen -S <session-name>
```

Start Label Studio

```bash
label-studio start
```
Detach the session (leave it running)

`Ctrl + A`, then `D`.

At this point, you can close the terminal and disconnect from your VM. Go to your browser and access the Label Studio instance using the hostname you set up in the Nginx configuration (e.g. `example.i3s.unice.fr`).

### For later: Other useful screen commands

You can reattach to the screen session later, or list all sessions (in case you forgot the name of the session you left running).

```bash
screen -r <name-of-session> # reattach to a session
screen -ls                  # list all sessions
```

## 5. Add Data to Label Studio

At this stage you should be able to access your Label Studio instance via the hostname you set up in the Nginx configuration (e.g. `example.i3s.unice.fr`) from any device with access to the internet as if you were using Label Studio in your local machine. You should see the Label Studio interface, but there are no annotation tasks or projects on it.

You can try to create a new project and upload data directly. However, uploading the data sometimes presents issues. Here we provide 2 work arounds to add data to your Label Studio project.

### Method 1: Use the Label Studio port explicitly

In your local machine, connect to the same network of your VM. For instance, if you are using a I3S VM then connect to the I3S VPN.

In your browser, instead of using just the hostname (e.g. `example.i3s.unice.fr`), use the port explicitly (e.g. `example.i3s.unice.fr:8080`). Now use Label Studio as you would on your local machine.

> Note: Remember that port `8080` is the default port for Label Studio. If you changed it, use the new port instead.

### Method 2: Transfer Label Studio Projects to the VM

If you have already created a Label Studio project on your local machine, you can transfer it to the VM. That will include all the data, annotations, and configurations.

**⚠️ Warning:** This method overwrites server data with your local project data.

All Label Studio projects' data is stored in a SQLite database file called `label_studio.sqlite3`. Normally, this file is located in the `~/.local/share/label-studio/` directory. You can find the location of the file using:

```bash
find / -name "label_studio.sqlite3" 2>/dev/null
```
In my case, the file is located in `/home/username/.local/share/label-studio/`.

To transfer the SQLite file from your local machine to the VM, use `scp` (secure copy protocol). Modify the following command with your own details:

```bash
SERVER="username@example-vm3.i3s.unice.fr" # the server address
DEST_DIR="/home/username/.local/share/label-studio/" # the destination directory in the server
ORIGIN_FILE="/home/username/.local/share/label-studio/label_studio.sqlite3" # the file to be transferred with its full path in the local machine

# Transfer the sqlite3 file from your local machine to the VM
scp "$ORIGIN_FILE" "$SERVER:$DEST_DIR"
```

> Changes made on the VM will not reflect on your local machine and vice versa.

## Apendix

### A. Rebooting the VM

Sometimes you need to reboot the VM to apply updates. This will most likely stop the Label Studio instance. Follow these steps to reboot and restart Label Studio.

Access you VM via SSH. For instance:

```bash
ssh username@ip_address.i3s.unice.fr
```

Reboot the VM

```bash
sudo reboot
```

Wait a few minutes.

Check if your Label Studio instance is still accessible through the internet by accessing the hostname (e.g. `example.i3s.unice.fr`) in your browser.
* If yes, you are done.
* If not, you need to either reattach to your `screen` session or create a new session. Follow the instructions of section [Run Label Studio as a Background Process](#4-run-label-studio-as-a-background-process), just skip the part of installing screen.

### B. Editing the nginx configuration

If in the future you need to make changes to the Nginx configuration use

```bash
sudo nano /etc/nginx/sites-available/label-studio
```

Make your changes and save them using `Ctrl + O`, `Enter`, `Ctrl + X`

Reload ngix to apply the changes using

```bash
sudo systemctl reload nginx
```

### C. Other useful nginx commands

```bash
sudo systemctl stop nginx       # Stop temporarily
sudo systemctl start nginx      # Start again
sudo systemctl disable nginx    # Prevent auto-start
sudo systemctl enable nginx     # Re-enable auto-start
```

### D. Scripts to transfer data between the VM and your local machine

If you decide to constantly transfer the Label Studio projects between your local machine and the VM you can take a look at the [scripts here](scripts). We describe there use cases below.

Many times your VM will not have a back up of the data. You might want to back up the Label Studio projects from the VM to your local machine. Check the script [`back_up_files_from_server.sh`](scripts/back_up_files_from_server.sh).

In case you have Label Studio projects on your local machine, but you want to import your projects from the VM to your local machine temporarily (for editing or testing purposes), check [`use_server_data_in_local.sh`](scripts/use_server_data_in_local.sh), [`transfer_data_to_server.sh`](scripts/transfer_data_to_server.sh), and [`restore_local_data.sh`](scripts/restore_local_data.sh).







