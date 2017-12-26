which asdf || git clone https://github.com/asdf-vm/asdf.git ~/.asdf
(asdf plugin-list | grep terraform) || asdf plugin-add terraform https://github.com/neerfri/asdf-terraform.git
cd terraform && asdf install
