# kalitools_tools_for_ubuntu
General Kali Linux security and pentesting tools for Ubuntu from Ubuntu's own repos or Kali tools individually.

## Basic tools
### nmap
### netcat-openbsd
### tcpdump
### wireshark
### traceroute
### dnsutils
### whois
### curl
### wget
### git
### jq
### openssh-client
### smbclient
### ldap-utils
### cifs-utils

## Web testing
  nikto \
  gobuster \
  ffuf \
  sqlmap \
  whatweb

## Passwords and hashes
  john \
  hashcat \
  hydra \
  hashid

## Metasploit

For Ubuntu, it is recommended to install Metasploit Framework using its own installation method and not add the Kali repository to Ubuntu.

```bash
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb \
  > /tmp/msfinstall

chmod +x /tmp/msfinstall
sudo /tmp/msfinstall
```

Check:
```bash
msfconsole
```

## Network traffic analysis
  wireshark \
  tshark \
  tcpdump \
  ettercap-common \
  bettercap

If you want to use Wireshark without sudo:
```bash
sudo usermod -aG wireshark "$USER"
```
