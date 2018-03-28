# mvlink

Move ORIGIN (file or folder) to DEST and create a symbolic ORIGIN to DEST

## EXAMPLE (Folder):

Move content of /var/www/html/config to data/config and create a symbolic : ```var/www/html/config -> /data/config```

```bash
mvlink.sh /var/www/html/config /data/config
```

## EXAMPLE (File):

Move /folder1/file1 to /folder2 as file2 and create a symbolic into /folder1 named file1 to point to /folder2/file2 : ```/folder1/file1 -> /folder2/file2```

```bash
mvlink.sh /folder1/file1 /folder2/file2
```
