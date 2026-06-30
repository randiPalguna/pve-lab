// Default Configuration ============
#set text(font: "Times New Roman", size: 11pt)
#set heading(numbering: "1.")
#set figure(supplement: "Gambar")
#set par(justify: true)
#let catatan(body) = block(
  fill: rgb("ececec"),                 
  stroke: (left: 4pt + rgb("696969")),  
  inset: (x: 1em, y: 1em),              
  radius: 2pt,                         
  width: 100%,                          
  [ *Catatan:* \ #body ]           
)
#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
    (top: 1.2pt + black)
  },
)
#let kode(body_header, body) = table(
  columns: 1fr,
  align: left,
  table.header(
    [#body_header],
  ),
  [#body],
  [
    #align(center)[#line(
      length: 102.5%,
      stroke: 1.2pt
    )]
  ],
)
// ==================================

// Cover Page =======================
#align(end)[
  #text(
    size: 18pt,
    "26 Juni 2026 – 30 Juni 2026"
  )
]

#align(horizon)[
  #text(
    size: 48pt,
    fill: rgb("#0b3a59ff"),
    weight: "bold",
    "Dokumentasi"
  )
  \ \
  #text(
    size: 28pt,
    "Technical Assessment - Cloud Engineer"
  )
  \ \ \
  #text(
    size: 18pt,
    "Oleh:"
  )
  \
  #text(
    size: 18pt,
    weight: "semibold",
    "Randi Palguna Artayasa"
  )
  \
  #text(
    size: 18pt,
    weight: "bold",
    "5025231020"
  )
  \ \ \
  #grid(
    columns: 2,
    gutter: 10pt,
    align: horizon,
    image("images/github-logo.svg", width: 48pt),
    text(size: 20pt, fill: rgb("#0b3a59ff"), weight: "bold", 
      [
        #link("https://github.com/randiPalguna/pve-lab")[
          github.com/randiPalguna/pve-lab
        ]
      ]
    )
  )
]
#align(bottom + end)[
  #text(
    size: 18pt,
    "ITS Nabu Recruitment 2026"
  )
]
// ==================================

// Default Configuration ============
#set page(numbering: "1") 
#show link: underline
// ==================================


// List of Contents, Table, and Images
#pagebreak()
#set text(font: "Times New Roman", size: 11pt, fill: rgb("#0b3a59ff"))
#outline(title: "Daftar Isi")
\
#outline(
  title: [Daftar Gambar],
  target: figure.where(kind: image),
)
\
#outline(
  title: [Daftar Kode],
  target: figure.where(kind: table),
)
#set text(font: "Times New Roman", size: 11pt, fill: black)
#pagebreak()
// ==================================



// Dokumentasi ======================
= Installasi Proxmox VE Lokal
Kita dapat menginstall file ISO Proxmox VE (PVE) pada internet. Kemudian kita menggunakan software Oracle VirtualBox untuk dapat menjalankan PVE di dalam host kita. Berikut adalah langkah-langkah untuk membuat VM PVE di dalam VirtualBox hingga mengkonfigurasi lingkungan PVE agar siap untuk melakukan provision container dan deployment service di dalamnya.

== Konfigurasi Virtual Machine (VM) untuk PVE pada VirtualBox
Setelah mengunduh software VirtualBox dan file ISO PVE, kita akan membuat VM PVE dengan langkah-langkah sebagai berikut:
+ Kita mengatur Linux sebagai OS dan Debian 64 Bit sebagai version OS-nya pada konfigurasi VM VirtualBox.
  #figure(
    image("images/1.1-virtualbox-vm-conf.png"),
    caption: [Konfigurasi image dan OS VirtualBox]
  )
+ Disini kita mengalokasikan 10800 MB memory, 9 CPU, dan 80.00 GB storage (sesuai dengan kapasitas host yang dapat dialokasikan).
+ Setelah itu kita perlu mengaktifkan fitur Nested VT-x/AMD-V pada VirtualBox. Hal ini dikarenakan kita menjalankan PVE sebagai VM dan PVE ingin membuat container atau VM lagi  di dalamnya, maka dibutuhkan nested virtualization.
  #figure(
    image("images/1.1-nested-virtualization.png", height: 54pt),
    caption: [Aktifkan fitur nested virtualization]
  )
+ Kemudian pada konfigurasi network VM, kita perlu menggunakan Bridged Adapter agar web GUI PVE dapat diakses dari jaringan LAN yang dimiliki host (laptop yang menjalankan VM PVE di dalam VirtualBox) tanpa perlu melakukan port forwarding. \
  Selain itu, Promiscuous Mode perlu diubah menjadi "Allow All" agar semua unicast frame (tanpa peduli source dan destination MAC addressnya) dapat keluar masuk secara bebas pada Bridged Adapter VirtualBox sehingga host manapun dalam LAN dapat mengakses container Proxmox VE yang memiliki MAC address tersendiri.
  #figure(
    image("images/1.1-network-conf.png"),
    caption: [Gunakan Bridged Adapter dan Promiscuous Mode "Allow All"]
  )
\
== Konfigurasi Instalasi PVE
Kita melakukan proses instalasi PVE menggunakan GUI agar lebih mudah. Berikut adalah langkah-langkah instalasi PVE hingga PVE dapat diakses di web browser host (laptop yang digunakan untuk menjalankan VM PVE):
+ Isi target disk, location, time zone, keyboard layout, root password, email sesuai dengan keinginan.
+ - Selanjutnya, IP Address (CIDR) dan Gateway akan otomatis terisi sendiri dimana jika kita menggunakan WiFi (atau ethernet) dari ISP, PVE akan otomatis mendapatkan IP-nya dari DHCP. Untuk saat ini, IP Address (CIDR) dan Gateway akan mengikuti IP yang diperoleh dari DHCP. Kita dapat menggantinya jika kita menggunakan LAN yang berbeda di kemudian hari.
  - Untuk Hostname (FQDN), kita bebas menamainya (namun tidak menggunakan reserved hostname) seperti "pve.lan".
  - DNS Server kita atur menjadi "1.1.1.1" agar memudahkan koneksi ke Internet jika menggunakan domain.
  #figure(
    image("images/1.2-pve-network.png"),
    caption: [Contoh konfigurasi PVE Node Network]
  )
+ Lakukan proses instalasi dan reboot. Setelah selesai, kita dapat shutdown VM PVE lalu kita perlu menghapus image installer ISO pada VM-nya di dalam setting VM PVE VirtualBox.
  #figure(
    image("images/1.2-remove-installer.png"),
    caption: [Hapus ISO installer pada setting storage VM PVE]
  )
+ Terakhir, jalankan kembali VM PVE dan akses web GUI PVE menggunakan IP address PVE yang diberikan DHCP yakni http://192.168.110.62 pada host (laptop) kita. Lalu masukan username "root" dan password yang sesuai.
  #figure(
    image("images/1.2-access-pve.png"),
    caption: [Web GUI PVE dapat diakses menggunakan IP address PVE Node]
  )

#pagebreak()
== Konfigurasi Jaringan pada PVE Node
Berikut adalah gambaran topologi jaringan yang akan kita konfigurasikan nantinya pada lingkungan PVE.
#figure(
  image("images/1.3-topologi-jaringan.png"),
  caption: [Topologi jaringan yang ingin dibangun dalam PVE Node]
)
Terdapat 2 Local Area Network (LAN) di dalam topologi jaringan tersebut. LAN yanng pertama adalah LAN yang disediakan dari Internet Service Provider (ISP), dimana end hosts terhubung melalui medium Wi-Fi. LAN yang kedua adalah private subnet yang dibuat di dalam PVE untuk keperluan jaringan container. Selanjutnya, terdapat Network Address Translation (NAT) dan IP forwarding di dalam PVE Node router. NAT dibutuhkan agar container dapat mengakses LAN ISP dan juga internet dengan menggunakan IP dari nic0. Sedangkan IP forwarding dibutuhkan agar end hosts yang terhubung dalam LAN ISP dapat mengakses service yang disediakan oleh container (misalnya nginx web server).

#catatan[
  Dibuatnya private subnet untuk container dikarenakan Wi-Fi dari access point router ISP memiliki batasan untuk hanya memperbolehkan device yang terhubung mengirimkan frame ke router dengan source MAC address dari device tersebut, tidak boleh source MAC address yang lain. Ini artinya ketika container mengirimkan unicast frame ke ISP router dengan source MAC Address-nya tersendiri, unicast frame tersebut akan di-drop oleh ISP router. Dalam kasus ini, frame yang dapat diterima oleh ISP router adalah frame dengan MAC address dari laptop yang menjalankan VM PVE ini.  
]

Untuk mengimplementasikan topologi jaringan tersebut, kita perlu masuk kedalam shell node pve kita dan mengatur konfigurasi network interface port dari PVE node (router). Berikut adalah langkah-langkahnya:
1. Atur konfigurasi interface port pada PVE node, yakni mengatur IP address dan gateway dari interface `nic0` dan `vmbr0` sesuai dengan gambar topologi jaringan diatas. Pada shell node pve, edit file `/etc/network/interfaces` dengan konfigurasi yang ditunjukan pada @kode-1.3.
#pagebreak()
#figure(
  kode(
    [`/etc/network/interfaces`],
    [
      ```
      auto lo
      iface lo inet loopback
      
      auto nic0
      iface nic0 inet static
              address 192.168.110.92/24
              gateway 192.168.110.1
      
      source /etc/network/interfaces.d/*
      
      auto vmbr0
      iface vmbr0 inet static
              address 192.168.200.1/24
              bridge-ports none
              bridge-stp off
              bridge-fd 0
              post-up   echo 1 > /proc/sys/net/ipv4/ip_forward
      
              ## containers to ISP LAN and internet ##
              post-up   iptables -t nat -A POSTROUTING -s 192.168.200.0/24 -o nic0 -j MASQUERADE
              post-down iptables -t nat -D POSTROUTING -s 192.168.200.0/24 -o nic0 -j MASQUERADE
      
              ## ISP LAN with PROTO tcp, PORT 80 -> containers with DST PORT 80, DST IP 192.168.200.2  ##
              post-up   iptables -t nat -A PREROUTING -i nic0 -p tcp --dport 80 -j DNAT --to-destination 192.168.200.2:80
              post-down iptables -t nat -D PREROUTING -i nic0 -p tcp --dport 80 -j DNAT --to-destination 192.168.200.2:80
      ```
    ]
  ),
  supplement: "Kode",
  caption: [Konfigurasi `/etc/network/interfaces` pada PVE node]
) <kode-1.3>
2. Selanjutnya, eksekusi perintah `ifreload -a` untuk memperbarui konfigurasi interface PVE node.

#catatan[
Terdapat script yang digunakan untuk mengotomatisasi konfigurasi interface pve node diatas. Script tersebut dapat dilihat pada link berikut:
- set_pve_network.sh: \
  #link("https://github.com/randiPalguna/pve-lab/blob/main/script/set_pve_network.sh")[github.com/randiPalguna/pve-lab/blob/main/script/set_pve_network.sh]
- set_pve_ip_forwarding.sh: \
  #link("https://github.com/randiPalguna/pve-lab/blob/main/script/set_pve_ip_forwarding.sh")[github.com/randiPalguna/pve-lab/blob/main/script/set_pve_ip_forwarding.sh]
]

== Konfigurasi SSH Authentication pada PVE Node
Untuk memudahkan penggunaan tool Ansible nantinya, PVE Node perlu memiliki public-key dari host yang akan mengkontrol PVE Node dan containernya, pada kasus ini host tersebut adalah laptop yang menjalankan PVE pada VirtualBox. Berikut adalah cara untuk mengkonfigurasi SSH Authentication:
+ Pada host yang menjadi control node, buatlah ssh key (private dan public key) dengan cara \ `ssh-keygen -t ed25519`
+ Setelah membuat ssh key, kita dapat membagikannya ke PVE Node dengan cara \ `ssh-copy-id -i ~/.ssh/id_ed25519.pub root@<PVE Node address>`

#pagebreak()
= Manajemen Template & Container
Berikut adalah @gambar-2 yang menunjukan gambaran container-container yang akan kita provision nantinya. Terdapat 3 container sebagai worker yang akan menyediakan layanan nginx web server, dan 1 container sebagai load_balancer yang akan mendistribusikan requests service ke ketiga worker tersebut. Adapun spesifikasi dari masing-masing container adalah 1 CPU, 512 MB memory, 1 GB disk, dan OS Debian 13. Untuk penerapan jaringannya, masing-masing container memiliki DNS 1.1.1.1 dengan IP dan Gateway yang dapat dilihat pada @gambar-2.
#figure(
  image("images/2-container-topology.png"),
  caption: [Topologi jaringan untuk container yang akan di-provision]
) <gambar-2>
#catatan[
  Sebelumnya pada *1. Instalasi Proxmox VE Lokal*, kita menggunakan jaringan LAN ISP dengan network address *192.168.110.0/24*. Kali ini pada *2. Manajemen Template & Container*, kita menggunakan jaringan myITS-WiFi dengan network address *10.125.128.0/18*. Dengan adanya perubahan ini, interface nic0 pada PVE node perlu diganti dengan network address jaringan myITS-WiFi di dalam file `/etc/network/interfaces`.
]
Untuk melakukan provision container di dalam PVE, kita dapat menggunakan tool Terraform di dalam host yang menjalankan PVE pada VirtualBox (host tersebut dapat disebut dengan control node). Terraform memungkinkan kita untuk membuat, mengedit, ataupun menghapus container-container PVE dengan cara mendeklarasikannya dalam bentuk kode konfigurasi  (Infrastructure as Code) yang bersifat deklaratif. Untuk memulai membuat container-container menggunakan Terraform, kita perlu mengunduh Terraform disini https://developer.hashicorp.com/terraform/install. Setelah mengunduhnya, berikut adalah cara menggunakan Terraform untuk melakukan provisioning contrainer template dan containernya:
1. Buatlah suatu direktori baru dan buatlah file bernama `main.tf` di dalamnya dengan konfigurasi awal seperti @kode-2-provider.
  #figure(
    kode(
      [`main.tf`],
      [
        ```
        terraform {
          required_version = "1.15.6"
          required_providers {
            proxmox = {
              version = "0.111.0"
              source  = "bpg/proxmox"
            }
          }
        }
        
        provider "proxmox" {
          endpoint      = var.endpoint
          username      = var.pve_username
          password      = var.pve_password
          insecure      = true
          random_vm_ids = true
        }
        ```
      ]
    ),
    supplement: "Kode",
    caption: [Konfigurasi awal `main.tf`]
  ) <kode-2-provider>

2. Karena kita menggunakan variables dalam melakukan assignment value di dalam main.tf, maka diperlukan file `variables.tf` dan `terraform.tfvars`. File `variables.tf` adalah tempat untuk mendeklarasikan variable-variable, sedangkan file `terraform.tfvars` adalah tempat untuk memberikan value terhadap beberapa variable yang telah didefinisikan, contohnya adalah string pve_password yang bersifat sensitif. Berikut adalah konfigurasi pada kedua file tersebut.
  #figure(
    kode(
      [`variables.tf`],
      [
        ```
        variable "endpoint" {
          type = string
        }
        
        variable "pve_node_name" {
          type    = string
          default = "pve"
        }
        
        variable "pve_username" {
          type      = string
          sensitive = true
        }
        
        variable "pve_password" {
          type      = string
          sensitive = true
        }
        ...
        ```
      ]
    ),
    supplement: "Kode",
    caption: [Konfigurasi `variables.tf`]
  )
  #figure(
    kode(
      [`terraform.tfvars`],
      [
        ```
        endpoint     = "https://10.125.128.253:8006/"
        pve_username = "root@pam"
        pve_password = "pve_pass"
        ...
        ```
      ]
    ),
    supplement: "Kode",
    caption: [Konfigurasi `terraform.tfvars`]
  )
3. Jalankan perintah `terraform init` pada direktori dengan file-file `main.tf`, `variables.tf`, dan `terraform.tfvars` di dalamnya.
4. Setelah proses inisialisai selesai, selanjutnya kita akan mendeklarasikan resource-resource yang nantinya akan dibuat pada PVE. Resource-resource tersebut diantaranya adalah
   - lxc image (`resource "proxmox_download_file"`), 
   - container template (`resource" proxmox_virtual_environment_container"`)
   - container asli (`resource "proxmox_virtual_environment_container"`)
   Container asli dapat dibuat dengan melakukan cloning dari container template untuk mengurangi pengulangan penulisan di dalam konfigurasi. Selain itu, untuk keperluan tool Ansible, contaner perlu memiliki ssh public-key dari control node. Hal tersebut secara otomatis dapat Terraform lakukan saat melakukan provision create, yakni dengan mendeklarasikan blok user_account di konfigurasi `main.tf` dan memberikan path public-key control node pada field `keys` di dalam blok tersebut.

   #catatan[
     - Anda dapat melihat konfigurasi deklarasi untuk masing-masing resource pada link berikut: #link("https://github.com/randiPalguna/pve-lab/blob/main/terraform/main.tf", [github.com/randiPalguna/pve-lab/blob/main/terraform/main.tf]).
     - Referensi konfigurasi provider bpg/proxmox dapat dilihat pada link: \
      #link("https://registry.terraform.io/providers/bpg/proxmox/0.110.0/docs", [registry.terraform.io/providers/bpg/proxmox/0.110.0/docs])
   ]
5. Setelah berhasil membuat dan mengkonfigurasikan file-file Terraform, kita dapat menjalankan perintah `terraform fmt` dan `terraform validate` untuk memperbaiki format dan kesalahan penulisan.
6. Selanjutnya kita dapat melakukan provisioning container menggunakan terraform dengan menjalankan perintah `terraform apply -parallelism=1` dan ketik "yes" ketika diminta prompt. Kita menggunakan option `-parallelism=1` untuk menghindari CT lock error, namun membuat provisioning tidak berjalan secara parallel atau memakan waktu lebih lama.
Berikut adalah @gambar-2-provision yang menunjukkan hasil provisioning container menggunakan Terraform.
#figure(
  image("images/2-terraform-provision.png", width: 75%),
  caption: [Hasil provisioning container menggunakan Terraform]
) <gambar-2-provision>

#pagebreak()
= Implementasi Layanan
Selanjutnya kita akan mengimplementasikan nginx web server pada workers container dan nginx load balancing pada load balancer container. Untuk mengimplementasikan layanan-layanan terseubt, kita dapat menggunakan tool Ansible untuk mengotomatisasikannya. Dengan Ansible, kita mengkonfigurasi seluruh container yang ada (dapat dikatakan sebagai "managed nodes") dengan konfigurasi layanan yang didefinisikan pada file `playbook.yaml`. Dalam kasus ini, eksekusi ansible playbook berasal dari host yang menjalankan PVE pada VirtualBox (dapat dikatakan sebagai "control node"). Namun control node tidak dapat mengakses managed nodes secara langsung karena perbedaan subnet jaringan, maka dari itu diperlukan node yang dapat dijadikan sebagai perantara atau penengah (dapat dikatakan sebagai "bastion node"). Dalam kasus ini, bastion node tersebut adalah PVE Node. Berikut adalah @gambar-3-ansible tentang bagaiamana control node dapat mengakses managed nodesnya.

#figure(
  image("images/3-ansible.png"),
  caption: [Diagram eksekusi kontrol Ansible melalui SSH]
) <gambar-3-ansible>

Berikut adalah langkah-langkah untuk menggunakan Ansible dalam mengimplementasikan layanan nginx pada managed nodesnya:
1. Buatlah direktori baru dan di dalamnya buatlah python environment dengan menjalankan command `python3 -m venv .venv`
2. Setelah itu, unduh Ansible dengan menjalankan command `pip install ansible`
3. Lalu buatlah file bernama `inventory.ini` dan deklarasikan managed nodes dan bastion node didalamnya. Kita dapat mengakses managed nodes dari control node dengan kode baris `ansible_ssh_common_args=-o ProxyJump=root@10.125.128.253` pada `inventory.ini`. Berikut @kode-3-inventory.ini adalah konfigurasi `inventory.ini`
  #figure(
    kode(
      [`inventory.ini`],
      [
        ```
        [pve]
        10.125.128.253
        
        [workers]
        192.168.200.2
        192.168.200.3
        192.168.200.4
        
        [load_balancer]
        192.168.200.5
        
        [pve:vars]
        ansible_user=root
        
        [workers:vars]
        ansible_user=root
        ansible_ssh_common_args=-o ProxyJump=root@10.125.128.253
        
        [load_balancer:vars]
        ansible_user=root
        ansible_ssh_common_args=-o ProxyJump=root@10.125.128.253
        ```
      ]
    ),
    supplement: "Kode",
    caption: [Konfigurasi `inventory.ini`]
  ) <kode-3-inventory.ini>
4. Selain itu, kita juga perlu membuat file bernama `ansible.cfg` untuk mengatur behavior dari Ansible seperti known_host ssh checking dan python interpreter warning message. Berikut konfigurasi `ansible.cfg`
  #figure(
    kode(
      [`ansible.cfg`],
      [
        ```
        [defaults]
        inventory = inventory.ini
        host_key_checking = False
        interpreter_python = auto_silent
        ```
      ]
    ),
    supplement: "Kode",
    caption: [Konfigurasi `ansible.cfg`]
  )  
5. Akhirnya kita membuat file `playbook.yaml` dan mendeklarasikan "play" untuk masing-masing node beserta tasks-nya. Misalnya adalah kita mendeklarasikan suatu play khusus untuk node workers dimana terdapat beberapa task didalamnya seperti:
  - Mengunduh package nginx
  - Mengkonfigurasi nginx file
  - Membuat konten html yang menarik
  - Melakukan restart pada service nginx
  Pada node load_balancer, kita mendeklarasikan task seperti berikut:
  - Mengunduh package nginx
  - Mengkonfgurasi nginx file untuk melakukan load balancing dengan round robin
  - Melakukan restart pada service nginx
  Pada node pve, kita mendeklarasikan task seperti berikut:
  - Menghapus semua iptables dengan chain PREROUTING
  - Menambahkan IP dan port forwarding untuk mengarahkan requests ke IP load_balancer.
6. Terakhir, jalankan perintah `ansible-playbook playbook.yaml` untuk mengeksekusi Ansible.
  #catatan[
    Anda dapat melihat konfigurasi `playbook.yaml` pada link berikut: \
    #link("https://github.com/randiPalguna/pve-lab/blob/main/ansible/playbook.yaml", [github.com/randiPalguna/pve-lab/blob/main/ansible/playbook.yaml])
  ]

  Berikut adalah hasil implementasi layanan menggunakan Ansible, dapat dilihat pada @gambar-3-service. Gambar tersebut membuktikan bahwa IP forwarding telah berhasil mengarahkan request ke node load_balancer serta layanan nginx telah berhasil dihidupkan oleh Ansible.
  #figure(
    image("images/3-service.png", height: 42%),
    caption: [Client melakukan request ke IP PVE node dengan interface nic0]
  ) <gambar-3-service>

  Untuk membuktikan bahwa load balancing berhasil diimplementasi, jalankan perintah: \ `curl -s 10.125.128.253 | grep "worker-"`
  #figure(
    image("images/3-load-balancing.png", width:100%),
    caption: [Hasil uji coba load balancing round robin]
  )

#pagebreak()
= Analisis Urgensi
ITS Nabu menawarkan sebuah platform _training_ _cybersecurity_ edukatif berbasis simulasi. Platform tersebut memiliki sesi _training_ interaktif yang dapat meningkatkan pengalaman pengguna dalam mempelajari bidang ilmu _cybersecurity_. Untuk membangun platform tersebut, dibutuhkan _container_ atau _virtual machine_ yang akan dijadikan objek studi di dalam suatu kasus masalah pada sesi _training_-nya. Misalnya dalam suatu kasus masalah, suatu _virtual machine_ telah disusupi sebuah _malware_ dimana pengguna perlu mencari _malware_ tersebut dan menganalisisnya. Ini membuktikan bahwa sesi _training_ yang ada pada platform memerlukan beberapa _container_ atau _virtual machine_, sehingga pemahaman dan keterampilan tentang Proxmox beserta manajemen _container_ dan _template_-nya sangatlah esensial karena teknologi virtualisasi ini merupakan _tools_ dan _resource_ yang *vital* dalam platform ITS Nabu.

Dengan memiliki keterampilan yang baik tentang Proxmox beserta _container_-nya, tim developer dapat mengurangi kesalahan atau _error_ dalam pengelolaan infrastruktur di ITS Nabu. Selain mengurangi kesalahan, dampak positif lainnya adalah komunikasi antar tim dalam melakukan hal yang bersifat teknis juga dapat lebih efektif dikarenakan konsep dan jargon-jargon yang ada dapat dipamahi dengan makna yang sama. Maka dari itu, keterampilan yang baik dari masing-masing anggota tim akan mengantarkan tim developer yang lebih kompeten, namun tetap dibutuhkan sifat kerendahan hati dari masing-masing anggota untuk dapat belajar, berkolaborasi, dan saling memenuhi satu sama lainnya.

#pagebreak()
= Penggunaan AI
Penulis menggunakan LLM atau AI (misalnya Claude dan Gemini) dalam mengerjakan tugas _technical assessment_ ini, khususnya dalam hal pemahaman konsep yang mungkin sudah dilupakan atau belum diketahui. Selain itu, LLM juga digunakan dalam menangani masalah baik itu masalah jaringan maupun masalah sintaks dalam penulisan kode. Terakhir, LLM juga digunakan dalam menghasilkan penulisan kode khususnya kode untuk `playbook.yaml` Ansible. Berikut adalah detail mengenai pengunaan AI yang dilakukan dalam menyelesaikan tugas ini.

== Penggunaan AI untuk Mempelajari Konsep
Dalam memahami konsep yang lupa ataupun belum diketahui, penulis bertanya ke LLM untuk mengisi ketidaktahuan tersebut. Contohnya mengenai konsep abstraksi jaringan logis pada PVE node. Selain itu juga konsep-konsep penggunaan tools Terraform dan Ansible juga digali menggunakan bantuan LLM. Namun penulis tetap menggunakan dokumentasi official yang tersedia di internet (seperti bpg/proxmox registry) dan tidak hanya bergantung dan mempercayai sepenuhnya kepada LLM.

== Penggunaan AI untuk Menangani Masalah
Dalam pengerjaannya, penulis tidak luput dengan kesalahan seperti misalnya kesalahan sintaks pada penulisan kode atau bahkan kesalahan logika. Penulis menggunakan LLM untuk mengkoreksi beberapa kesalahan yang muncul dan mempelajarinya.

== Penggunaan AI untuk Menghasilkan Kode
Terakhir, penulis juga menggunakan LLM untuk menghasilkan sebuah kode, tepatnya pada kode `playbook.yaml`. Penulis masih belum familier dengan Ansible dan memiliki ketertarikan untuk menggunakkanya dalam menyelesaikan tugas ini. Tidak terbatas dengan kurangnya pemahaman mengenai Ansible, penulis juga perlu memahami lebih lanjut mengenai konsep jaringan beserta alat untuk melakukan manajemen _container_ seperti Proxmox dan Terraform.

// ==================================
