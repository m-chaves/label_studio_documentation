# Label Studio Documentation

This repository contains a collection of guides and resources for working with [Label Studio](https://labelstud.io/), an open-source data annotation tool.

The documents are intended to support both new and experienced users in deploying, configuring, and extending Label Studio for a variety of use cases.

## Documentation Overview

### 1. [`setup.md`](setup.md)
A beginner-friendly guide that introduces the core features of Label Studio. It covers installation, project creation, dataset import, interface editing, and how to navigate the user interface.

### 2. [`ngrok_integration.md`](ngrok_integration.md)
Explains how to integrate Label Studio with [ngrok](https://ngrok.com/) to expose your local instance to the internet. By using Label Studio and ngrok integration you can simply share a link with your collaborator and they will have access to your Label Studio annotation tool, even if it's running on your local machine.

### 3. [`virtual_machine_host.md`](virtual_machine_host.md)
A guide to installing and hosting Label Studio on a Linux-based virtual machine (VM). This is usedful when you want your annotation tool to be accessible 24/7 from any device with internet access. Includes setup instructions using Nginx or direct port exposure, running Label Studio in the background, and tips for transferring projects to the server.

### 4. [`interface_examples.md`](interface_examples.md)
Demonstrates how to customize the labeling interface using XML-like configuration code. Includes code snippets and examples for tailoring the UI to different annotation tasks.

