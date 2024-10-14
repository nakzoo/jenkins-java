
# gcp komutlarını localimizde çalıştırıyoruz.
# Bilgilerimizi tanımlıyoruz.
gcloud auth login


# Projelerimizi listeler
gcloud projects  list 


# Proje seçiyoruz.
gcloud config set  <PROJECT_ID>


# Zone seçimi
gcloud config set compute/zone us-central1-a


# GCP  instence kurulumu
gcloud compute instances create jenkins \
    --machine-type f1-micro \
    --image-family ubuntu-2004-lts \
    --image-project ubuntu-os-cloud \
    --boot-disk-size 40GB \
    --preemptible



----------------------------------------------------------------------------------------
# GCP için  güvenik duvarı yapolandırması port 8080, jenkins
gcloud compute firewall-rules create allow-8080 \
    --allow tcp:8080 \
    --target-tags web-server \
    --description "Allow traffic on port 8080" \
    --direction INGRESS


#  port a erişim içn intence güvenlik duvarı ayarları
gcloud compute instances add-tags jenkins \
    --tags web-server \
    --zone us-central1-f


*
# GCP için  güvenik duvarı yapolandırması port 9000, sonarqube
gcloud compute firewall-rules create allow-9000 \
    --allow tcp:9000 \
    --target-tags web-server2 \
    --description "Allow traffic on port 9000" \
    --direction INGRESS


#  port a erişim içn intence güvenlik duvarı ayarları
gcloud compute instances add-tags jenkins \
    --tags web-server2 \
    --zone us-central1-f



----------------------------------------------------------------------------------------
# GCP instence da  jenkins kurulumu

curl -s https://raw.githubusercontent.com/hakanbayraktar/ibb-tech/refs/heads/main/devops/jenkins/install/jenkins-install.sh | sudo bash


-----------------------------------------------------------------------------------------
# GCP instence da Trivy kurulumu

sudo apt-get install wget apt-transport-https gnupg lsb-release -y

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

sudo apt-get update

sudo apt-get install trivy -y


-----------------------------------------------------------------------------------------
# GCP de kurduğumuz jenkins adlı instence da AWS kurulumu

sudo apt install curl unzip -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip

sudo ./aws/install


-----------------------------------------------------------------------------------------
# GCP instence da Docker install

curl -s https://raw.githubusercontent.com/hakanbayraktar/ibb-tech/refs/heads/main/docker/ubuntu-24-docker-install.sh | sudo bash

sudo chmod 666 /var/run/docker.sock

sudo usermod -aG docker jenkins

sudo usermod -aG docker ubuntu

-----------------------------------------------------------------------------------------
# GCP kubectl kurulumu

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl


-----------------------------------------------------------------------------------------

GCP instence üzerinden sonarqube 

docker run -d --name sonarqube -p 9000:9000 sonarqube
-----------------------------------------------------------------------------------------
















