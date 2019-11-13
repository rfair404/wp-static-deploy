#!/usr/bin/env bash
set -o allexport
[[ -f .env ]] && source .env
set +o allexport

install_wp() {
    wp config create --dbname=$WP_DB_NAME --dbuser=$WP_DB_USER --dbpass=$WP_DB_PASS --dbhost=$WP_DB_HOST --allow-root
    wp db reset --allow-root --yes
    wp core install --url=$WP_URL --title="$WP_TITLE" --admin_user=$ADMIN_USER --admin_email=admin@example.com --admin_password=password --skip-email --allow-root
    RFAIR_USER=$(wp user create rfair404 rfair404@gmail.com --role=author --first_name="Russell" --last_name="Fair" --porcelain --allow-root)
    wp rewrite structure '/%postname%/' --allow-root
}

activate_plugins() {
 wp plugin activate static-html-output-plugin --allow-root
}

delete_posts() {
    wp post delete $(wp post list --field=ID --format=csv --post_type=post,page --allow-root) --allow-root
}

create_homepage() {
    HOME_PAGE_ID=$(wp post create --post_author=$RFAIR_USER --post_date=2019-11-13 --post_title="Welcome to WP Static"  --post_status=publish --post_type=page --comment_status=closed --post_modified=2019-11-13 --porcelain --allow-root ./config/homepage.md)
    wp option set show_on_front page --allow-root
    wp option set page_on_front $HOME_PAGE_ID --allow-root
    wp post meta update $HOME_PAGE_ID _is_githuber_markdown 1 --allow-root
}

configure_wp2static() {
    wp option update wp2static-options $(wp eval-file ./config/wp2static.php --allow-root) --allow-root
}
install_wp
activate_plugins
delete_posts
create_homepage
configure_wp2static