#!/bin/bash
IFS=$'\n'

cd /root/wordpress-codingbee/nav-menus

menu_title=${1}
echo "About to create menu called ${menu_title}"
menu_id=`wp menu create "${menu_title}" --porcelain --path=/var/www/html`
echo "The menu ${menu_title} has the id: ${menu_id}"

for line in `cat /root/wordpress-codingbee/nav-menus/${menu_title}.csv`; do
  echo "about to process: $line"
  post_title=`echo ${line} | awk 'BEGIN {FS=":::"} {print $1}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
  parent_post_title=`echo ${line} | awk 'BEGIN {FS=":::"} {print $2}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
  menu_label=`echo ${line} | awk 'BEGIN {FS=":::"} {print $3}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`

  echo "The post title is:          ${post_title}"
  echo "The parent post title is:   ${parent_post_title}"
  echo "The menu item label is:     ${menu_label}"

  if [[ ${parent_post_title} == 'null' && ${menu_label} == 'null' ]] ; then
    echo 'SCENARIO-1 - About to add a simple parent menu item'
    post_id=`wp post list --path=/var/www/html --fields=ID,post_title | grep "${post_title}" | awk '{print $2;}'`
    set -x
    wp menu item add-post ${menu_title} ${post_id} --path=/var/www/html   || exit 1
    set +x
  fi

  if [[ ${parent_post_title} != 'null' && ${menu_label} == 'null' ]] ; then
    echo 'SCENARIO-2 - About to add a simple child menu item'
    post_id=`wp post list --path=/var/www/html --fields=ID,post_title | grep "${post_title}" | awk '{print $2;}'`
    parent_post_id=`wp post list --path=/var/www/html --fields=ID,post_title | grep "${parent_post_title}" | awk '{print $2;}'`
    db_id=`wp menu item list ${menu_title} --path=/var/www/html --fields=db_id,title,object_id | grep "${parent_post_id} *|$" | awk '{print $2}'`
    set -x
    wp menu item add-post ${menu_title} ${post_id} --parent-id=${db_id} --path=/var/www/html   || exit 1
    set +x
  fi


  if [[ ${parent_post_title} == 'null' && ${menu_label} != 'null' ]] ; then
    echo 'SCENARIO-3 - About to add a parent menu item with custom label'
    post_id=`wp post list --path=/var/www/html --fields=ID,post_title | grep "${post_title}" | awk '{print $2;}'`
    set -x
    wp menu item add-post ${menu_title} ${post_id} --title=${menu_label} --path=/var/www/html    || exit 1
    set +x
  fi

  if [[ ${parent_post_title} != 'null' && ${menu_label} != 'null' ]] ; then
    echo 'SCENARIO-4 - About to add a child menu item with custom menu'
    post_id=`wp post list --path=/var/www/html --fields=ID,post_title | grep "${post_title}" | awk '{print $2;}'`
    parent_post_id=`wp post list --path=/var/www/html --fields=ID,post_title | grep "${parent_post_title}" | awk '{print $2;}'`
    db_id=`wp menu item list ${menu_title} --path=/var/www/html --fields=db_id,title,object_id | grep "${parent_post_id} *|$" | awk '{print $2}'`
    set -x
    wp menu item add-post ${menu_title} ${post_id} --title=${menu_label} --parent-id=${db_id} --path=/var/www/html   || exit 1
    set +x
  fi


done
# wp sidebar list --fields=name,id --path=/var/www/html
# wp widget list left --path=/var/www/html
# wp widget add custom-menu-wizard left --path=/var/www/html
