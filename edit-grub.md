# Edit grub
```sh
sudo grub-mkconfig | \
grep -iE "menuentry 'Ubuntu, with Linux" | \
awk '{print i++ " : "$1, $2, $3, $4, $5, $6, $7}'
```

```sh
grep GRUB_DEFAULT /etc/default/grub
sudo sed -i -e 's/GRUB_DEFAULT=0/GRUB_DEFAULT="1>2"/g' /etc/default/grub
sudo grep GRUB_DEFAULT /etc/default/grub
sudo update-grub
```
