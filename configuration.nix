{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel Args
  boot.kernelParams = [
    "nvidia.NVreg_TemporaryFilePath=/var/tmp" 
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "mitigations=off"
    "nowatchdog"
    "nmi_watchdog=0"
    "transparent_hugepage=always"
    "page_alloc.shuffle=1"
    "split_lock_detect=off"
    "tsc=reliable"
    "clocksource=tsc"
  ];

  # Kernel Modules
  boot.kernelModules = [ "thinkpad_acpi" ];

  networking.hostName = "terminalindex"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Enable X11
  services.xserver.enable = true;

  # Define GPU drivers 
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable NVIDIA GPU
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.prime = {
    sync.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Enable Hyprland
  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;

  # Enable flatpak
  services.flatpak.enable = true;

  # Setup Drive Mounts
  fileSystems."/mnt/steam_ntfs" = {
    device = "/dev/disk/by-uuid/78686F1B686ED780";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "exec"        
      "umask=000"
      "nofail"
      "noatime"
    ];
  };

  environment.etc."crypttab".text = ''
    crypt_storage /dev/disk/by-uuid/512dd705-1aa3-4a7d-ab06-d87a497b6625 /root/secrets/secure_drive.key luks
  '';

  fileSystems."/mnt/secure_data" = {
    device = "/dev/mapper/crypt_storage";
    fsType = "ext4"; 
    options = [ "rw" "nofail" "noatime" ];
  };

  # Enable ly login manager
  services.displayManager.ly.enable = true;

  # Enable ollama Local AI
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable ZRAM
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 12;
  };

  # Kernel Tweaks
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";

  # Enable Thermal Management
  services.thermald.enable = true;

  # Enable CUPS (Printing support)
  services.printing.enable = true;

  # Enable Samba
  services.samba.enable = true;

  # Enable Gamemode
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 1; 
        nv_powermizer_mode = 1;
      };
    };
  };

  # Enable Tailscale VPN - PRETTY IMPORTANTE
  services.tailscale.enable = true;

  # I fucking hate you, but... enable Docker (at least not podman)
  virtualisation.docker.enable = true;

  # Enable ThinkPad Fan Management
  services.thinkfan = {
    enable = true;
    levels = [
      [0 0 67]
      [1 55 70]     
      [3 65 80]      
      [7 75 90]      
      [127 85 32767]
    ];
  };

  # Enable Intel Undervolt
  services.undervolt = {
    enable = true;
    coreOffset = -100;
    uncoreOffset = -80;
    gpuOffset = -50;
    analogioOffset = -20;

    p1 = {
      limit = 45;
      window = 28;
    };
    p2 = {
      limit = 65;
      window = 2;
    };
  }; 

  # Enable usbmuxd
  services.usbmuxd.enable = true;

  # Enable libvirtd (Virtual Machines' Daemon)
  virtualisation.libvirtd.enable = true;

  # Enable Waydroid (Android Container)
  virtualisation.waydroid.enable = true;

  # Enable OpenSSH Daemon
  services.openssh.enable = true;

  # Enable AppImage support
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.nix-ld.enable = true;

  # Enable pipewire audio session
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ti = {
    isNormalUser = true;
    description = "karol szołtysek";
    extraGroups = [ "networkmanager" "wheel" "plugdev" "dialout" ];
    packages = with pkgs; [
      google-chrome
      git
      telegram-desktop
      btop
      fastfetch
      wget
      curl
      vlc
      gimp
      krita
      audacity
      bitwarden-desktop
      antigravity
      lazygit
      lazydocker
      eza
      mpv
      imv
      feh
      strawberry
      handbrake
      rawtherapee
      lutris
      heroic
      bottles
      prismlauncher
      lmms
      mangohud
      gamescope
      sunshine
      arduino-ide
      wireshark
      nmap
      sqlmap
      bambu-studio
      brlaser
      deluge
      aria2
      croc
      ghidra
      imagemagick
      optipng
      lftp
      inkscape
      libreoffice
      fuzzel
      wlogout
      mako
      grim
      slurp
      wl-clipboard
      nwg-look
      nwg-displays
      hyprpaper
      hyprpicker
      qt6Packages.qt6ct
      wlr-randr
      waybar
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    xdg-user-dirs
    nano
    sbctl
    fzf
    bat
    obs-studio
    steam
    libimobiledevice
    usbmuxd
    go
    unzip 
    yazi
    nnn
    ripgrep
    fd
    kitty
    alacritty
    loupe
    arduino-cli
    certbot
    rclone
    restic
    backrest
    intel-undervolt
    thinkfan
    sassc
    glib
    libxml2
    imagemagick
    dialog
    jdk8
    jdk11
    jdk17
    jdk21
    jdk25
    nautilus
    trayscale
    pavucontrol
    open-webui
  ];

  fonts.packages = with pkgs; [
	noto-fonts
	roboto
	roboto-mono
	nerd-fonts.jetbrains-mono
	nerd-fonts.fira-code
	nerd-fonts.hack
	nerd-fonts.meslo-lg
	nerd-fonts.ubuntu
	nerd-fonts.ubuntu-mono
	nerd-fonts.victor-mono
	nerd-fonts.caskaydia-mono
	nerd-fonts.droid-sans-mono
  ];

  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Roboto" "Noto Sans" ];
    serif = [ "Noto Serif" ];
    monospace = [ "JetBrainsMono Nerd Font" "Roboto Mono" ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
