# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#

rules = {
    0 => {
        lists: [:all_lists, :show, :create, :update, :update_members, :delete],
        cards: [:all_cards, :show, :create, :update, :delete],
        comments: [:all_comments, :show, :create, :update, :delete]
    },
    1 => {
        lists: [:all_lists, :show],
        cards: [:all_cards, :show, :create, :update, :delete],
        comments: [:all_comments, :show, :create, :update, :delete]
    }
}
rules_objects = []
rules.map do |user_type, value|
  value.map do |controller_name, sub_value|
    sub_value.map do |action_name|
      rules_objects.push({user_type: user_type, controller_name: controller_name, action_name: action_name})
    end
  end
end
# p rules_objects
Rule.create(rules_objects)
