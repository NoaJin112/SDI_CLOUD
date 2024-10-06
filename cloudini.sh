wget -q https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img     
qemu-img resize jammy-server-cloudimg-amd64.img 50G



qm create 750 --name "ubuntu-2404-cloudinit-template" --ostype l26 \
    --memory 2048 \
    --agent 1 \
    --bios ovmf --machine q35 --efidisk0 POOL-VM1320:0,pre-enrolled-keys=0 \
    --cpu host --socket 1 --cores 2 \
    --vga serial0 --serial0 socket  \
    --net0 virtio,bridge=vmbr0

qm importdisk 750 jammy-server-cloudimg-amd64.img POOL-VM1320
qm set 750 --scsihw virtio-scsi-pci --virtio0 POOL-VM1320:vm-750-disk-1,discard=on
qm set 750 --boot order=virtio0
qm set 750 --ide2 POOL-VM1320:cloudinit

cat << EOF | tee /var/lib/vz/snippets/vendor.yaml
#cloud-config
packages:
    - wget
runcmd:
    - apt update
    - apt install -y qemu-guest-agent
    - systemctl start qemu-guest-agent
    - wget https://raw.githubusercontent.com/jhbos/SDI2425-442701/refs/heads/main/Desktop/my_project/zebbix_agent.sh?token=GHSAT0AAAAAACWYZ6XEA3UPWT6PSKODFBRMZYCV5IA
    - chmod 777 zebbix_agent.sh
    - ./zebbix_agent.sh
    - #################################### change nameserver ip 127.0.1.1 #########->>>>>>
    - wget https://raw.githubusercontent.com/jhbos/SDI2425-442701/refs/heads/main/Desktop/my_project/espocrm.sh?token=GHSAT0AAAAAACWYZ6XEW53RHRCAF2CMCUBIZYCV6ZA
    - chmod 777 espocrm.sh
    - ./espocrm.sh
    - reboot
EOF

export CUSTOM_USER_NAME=ubuntu
export CUSTOM_USER_PASSWORD=password

qm set 750 --cicustom "vendor=cephfs:snippets/vendor.yaml"
qm set 750 --tags ubuntu-template,22.04,cloudinit
qm set 750 --ciuser $CUSTOM_USER_NAME --ciupgrade 1
qm set 750 --cipassword $(openssl passwd -6 $CUSTOM_USER_PASSWORD)
qm set 750 --sshkeys ~/.ssh/authorized_keys
qm set 750 --ipconfig0 ip=dhcp

qm cloudinit update 750
qm template 750



