module ApplicationHelper
  def current_user_include_tag
    if current_user
      javascript_tag "window.currentUser = #{sanitized_current_user.to_json}"
    else
      javascript_tag "window.currentUser = null"
    end
  end

  def sanitized_current_user
    if current_user
      {
        isAdmin: current_user.admin,
      }
    end
  end
end
