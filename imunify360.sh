#!/bin/bash
# Nhập tên miền từ người dùng
read -p "Nhập tên miền cần cài ImunifyAV: " domain

# Loại bỏ thuộc tính chống sửa đổi
chattr -i /www/wwwroot/$domain/.user.ini

# Tìm và xóa các tệp cụ thể trong thư mục
find /www/wwwroot/$domain/ -maxdepth 1 -type f \( -name ".htaccess" -o -name ".user.ini" -o -name "404.html" -o -name "index.html" \) -exec rm -f {} \;

# Tạo thư mục
mkdir -p /etc/sysconfig/imunify360

# Tạo file integration.conf
touch /etc/sysconfig/imunify360/integration.conf

# Ghi nội dung vào integration.conf
echo "[paths]
ui_path = /www/wwwroot/$domain
ui_path_owner = root:root

[pam]
service_name = system-auth

[integration_scripts]
users = /root/get-users-script.sh
domains = /root/get-domains-script.sh
admins = /root/get-admins-script.sh" > /etc/sysconfig/imunify360/integration.conf

# Tạo file get-users-script.sh
echo '#!/bin/bash

echo "{
  \"data\": [
    {
      \"id\": 1000,
      \"username\": \"admin\",
      \"owner\": \"root\",
      \"package\": {
        \"name\": \"package\",
        \"owner\": \"root\"
      },
      \"email\": \"admin@'$domain'\",
      \"locale_code\": \"EN_us\"
    }
  ],
  \"metadata\": {
    \"result\": \"ok\"
  }
}"' > /root/get-users-script.sh

# Tạo file get-domains-script.sh
echo '#!/bin/bash

echo "{
  \"data\": {
    \"'$domain'\": {
      \"document_root\": \"/www/wwwroot/'$domain'/\",
      \"is_main\": true,
      \"owner\": \"admin\"
    }
  },
  \"metadata\": {
    \"result\": \"ok\"
  }
}"' > /root/get-domains-script.sh

# Tạo file get-admins-script.sh
echo '#!/bin/bash

echo "{
  \"data\": [
    {
      \"name\": \"admin\",
      \"unix_user\": \"admin\",
      \"locale_code\": \"EN_us\",
      \"email\": \"admin@'$domain'\",
      \"is_main\": true
    }
  ],
  \"metadata\": {
    \"result\": \"ok\"
  }
}"' > /root/get-admins-script.sh

# Tải và chạy imav-deploy.sh
wget https://repo.imunify360.cloudlinux.com/defence360/i360deploy.sh -O i360deploy.sh

read -p "Nhập key: " license
bash i360deploy.sh --key $license

#wget https://repo.imunify360.cloudlinux.com/defence360/imav-deploy.sh -O imav-deploy.sh
#bash imav-deploy.sh

# Khởi động ImunifyAV
#systemctl start imunify-antivirus
#systemctl enable imunify-antivirus
#systemctl status imunify-antivirus
