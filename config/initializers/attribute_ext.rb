#
# Use User objects as role in safe_attribute statements.
#
AttributeExt::SafeAttributes.role_mapper do |role|
  role.is_a?(User) ? role : User.current
end
