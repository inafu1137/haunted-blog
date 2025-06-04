json.users do
  json.array! @users do |user|
    json.partial! 'api/liking_users/user', user: user
  end
end

json.destroy_path @destroy_path
