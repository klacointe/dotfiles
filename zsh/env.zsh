path=(
  /bin
  /sbin
  /usr/bin
  /usr/sbin
  /usr/local/bin
  /usr/local/sbin
  $HOME/bin
  $HOME/.local/bin
  $HOME/.awless
  /usr/local/go/bin
  $HOME/dev/gitleaks
  $HOME/.tfenv/bin
  $HOME/.tgenv/bin
  /snap/bin
  .
)

export VISUAL=nvim
export EDITOR=nvim
export TERRAGRUNT_PARALLELISM="5"
export TERRAGRUNT_DOWNLOAD="$HOME/.terraform.d/terragrunt_cache"
# export AWS_ACCESS_KEY_ID=$(aws --profile default configure get aws_access_key_id)
# export AWS_SECRET_ACCESS_KEY=$(aws --profile default configure get aws_secret_access_key)
