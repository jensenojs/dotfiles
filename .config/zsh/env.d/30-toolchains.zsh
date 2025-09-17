# 额外的开发工具链 - Additional Development Toolchains

# RISC-V 工具链
prepend_to_path_if_exists "/usr/local/opt/riscv-gnu-toolchain/bin"

# MySQL 客户端(Homebrew 安装)
if is_macos; then
  for mysql_bin in \
    /opt/homebrew/opt/mysql-client@8.4/bin \
    /opt/homebrew/opt/mysql-client/bin \
    /usr/local/opt/mysql-client/bin; do
    prepend_to_path_if_exists "$mysql_bin"
  done
fi
