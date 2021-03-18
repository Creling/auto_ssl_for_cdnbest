#!/bin/bash

before_show_menu() {
    echo && echo -n -e "${yellow}* 按回车返回主菜单 *${plain}" && read temp
    show_menu
}

show_menu() {
    echo -e "
    ${green}证书自动申请${plain} ${red}${NZ_VERSION}${plain}
    ${green}0.${plain}  退出脚本
    ————————————————-
    ${green}1.${plain}  安装依赖
    ${green}2.${plain}  申请证书（手动输入待申请域名）
    ${green}3.${plain}  申请证书（从文件读取域名列表，每行一个）
    "
    echo && read -p "请输入选择 [0-3]: " num

    case "${num}" in
    0)
        exit 0
        ;;
    1)
        install_dependence
        ;;
    2)
        read_domains_from_input
        ;;
    3)  
        read_domains_from_file
        ;;
    *)
        echo -e "${red}请输入正确的数字 [0-3]${plain}"
        ;;
    esac
}

read_domains_from_input (){
    echo && read -p "请输入域名: " domain 
    echo "请耐心等待..."
    
    issue_cert ${domain}

    before_show_menu
}

read_domains_from_file (){
    echo && read -p "请输入存放域名的文件: " file 
    echo "请耐心等待..."

    bak=$IFS 

    IFS=$'\n'
    
    for domain in `cat ${file}`
    do
        issue_cert ${domain}
    done

    IFS=$bak

    before_show_menu

}

issue_cert(){
    
    domain=${1}

    /root/.acme.sh/acme.sh --issue -d ${domain} --standalone > /dev/null

    mkdir certs
    cp /root/.acme.sh/${domain}/fullchain.cer certs/${domain}.cer
    cp /root/.acme.sh/${domain}/${domain}.key certs/${domain}.key
    
    if [[ $? == 0 ]]; then

        echo "域名 ${domain} 的证书申请成功，存放在当前目录下的certs文件夹中"
    else
        echo "域名 ${domain} 的证书申请失败"
    fi
}

install_dependence(){
    yum makecache
    yum install socat
    curl https://get.acme.sh | sh -s email=976969374@qq.com
    source ~/.bashrc

    before_show_menu
}


if [[ $# > 0 ]]; then
    case $1 in
    "install_dependence")
        install_dependence 
        ;;
    "read_from_input")
        read_domains_from_input $2
        ;;
    "read_from_file")
        read_domains_from_file $2
        ;;
    *) show_usage ;;
    esac
else
    show_menu
fi
