#!/usr/bin/env bash
set -o allexport
[[ -f ../config/.env ]] && source ../config/.env
set +o allexport

echo $WP_DB_NAME
echo $WP_DB_USER
echo $WP_DB_PASS
echo $WP_DB_HOST
echo $WP_URL
echo $WP_TITLE
echo $ADMIN_USER
echo $GH_TOKEN

install_wp() {
    wp config create --dbname=$WP_DB_NAME --dbuser=$WP_DB_USER --dbpass=$WP_DB_PASS --dbhost=$WP_DB_HOST --allow-root
    wp db reset --allow-root --yes
    wp core install --url=$WP_URL --title="$WP_TITLE" --admin_user=$ADMIN_USER --admin_email=admin@example.com --admin_password=password --skip-email --allow-root
    RFAIR_USER=$(wp user create rfair404 rfair404@gmail.com --role=author --first_name="Russell" --last_name="Fair" --porcelain --allow-root)
    wp rewrite structure '/%postname%/' --allow-root
}

activate_plugins() {
    wp plugin activate static-html-output-plugin --allow-root
#    wp plugin activate wp-githuber-md --allow-root
}

delete_posts() {
    wp post delete $(wp post list --field=ID --format=csv --post_type=post,page --allow-root) --allow-root
}

create_homepage() {
    HOME_PAGE_ID=$(wp post create --post_author=$RFAIR_USER --post_date=2019-11-13 --post_title="Welcome to WP Static"  --post_status=publish --post_type=page --comment_status=closed --post_modified=2019-11-13 --porcelain --allow-root ../config/homepage.md)
    wp option set show_on_front page --allow-root
    wp option set page_on_front $HOME_PAGE_ID --allow-root
    wp post meta update $HOME_PAGE_ID _is_githuber_markdown 1 --allow-root
}

configure_wp2static() {
#    wp option update wp2static-options $(wp eval-file ../config/wp2static.php --allow-root) --allow-root
    wp wp2static options set targetFolder /var/www/html/static-cli --allow-root
    wp wp2static options set selected_deployment_option github --allow-root
    wp wp2static options set baseUrl https://rfair404.github.io/wp-static-deploy --allow-root
    wp wp2static options set baseUrl-github https://rfair404.github.io/wp-static-deploy --allow-root
    wp wp2static options set ghBranch gh-pages --allow-root
    wp wp2static options set ghToken $GH_TOKEN --allow-root
    wp wp2static options set ghRepo rfair404/wp-static-deploy --allow-root
    wp wp2static options set ghCommitMessage "site update" --allow-root
}

generate_wp2static() {
    wp wp2static generate --allow-root
    wp wp2static deploy --allow-root
}

install_wp
activate_plugins
delete_posts
create_homepage
configure_wp2static
generate_wp2static

echo $WP_DB_NAME
echo $WP_DB_USER
echo $WP_DB_PASS
echo $WP_DB_HOST
echo $WP_URL
echo $WP_TITLE
echo $ADMIN_USER
echo $GH_TOKEN