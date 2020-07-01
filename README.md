# Certificate Manager cookbook for your Chef

## NOTE: This cookbook is Linux-only, has several commands which are executed as shell script.

## Requirements
- sh/bash
- ruby  :)

## Usage

```ruby
certificate_manager_add '/file/path.p12' do
  content         'cert content'     # required
  is_base64       true               # default: false
  owner           'root'             # default: "root"
  group           'root'             # default: "root"
  mode            '0600'             # default: "600"
  expiration_date 'Jun 29 2022 GMT'  # default: ""
end
```

- `is_base64` if `true` will be base64 decoded before saving
- `expiration_date` is parsed by `Time.parse()` and will raise exception if expired

