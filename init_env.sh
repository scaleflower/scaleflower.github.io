#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 重置颜色

# 配置参数
REPO_DIR="scaleflower.github.io"
REPO_URL="git@github.com:scaleflower/scaleflower.github.io.git"
BRANCH="hexo"
THEME_NAME="anzhiyu"  # <== 新增主题名称常量
FORCE_CLEAN=false

# 显示欢迎信息
echo -e "${GREEN}🚀 Hexo 博客环境初始化脚本 v2.1${NC}"
echo -e "${YELLOW}📅 最后更新: 2023-12-10${NC}"
echo -e "${YELLOW}✨ 包含 anzhiyu 主题集成${NC}\n"

# ... [保持原有 clean_environment 函数不变] ...

# 安装主题子模块函数 <== 新增函数
install_theme() {
    echo -e "\n${GREEN}🎨 强制安装 anzhiyu 主题...${NC}"
    
    # 清理旧主题
    if [ -d "themes/$THEME_NAME" ]; then
        echo -e "${YELLOW}🗑  移除旧主题...${NC}"
        git rm --cached themes/$THEME_NAME >/dev/null 2>&1 || true
        rm -rf themes/$THEME_NAME
    fi

    # 添加子模块
    echo -e "${YELLOW}📦 添加主题子模块...${NC}"
    git submodule add --force https://github.com/anzhiyu-c/hexo-theme-anzhiyu.git themes/$THEME_NAME

    # 初始化子模块
    echo -e "${YELLOW}🔧 初始化子模块...${NC}"
    git submodule update --init --recursive --remote

    # 安装主题依赖
    echo -e "${YELLOW}📦 安装主题专属依赖...${NC}"
    (cd themes/$THEME_NAME && npm install --loglevel=error)

    # 修复权限
    if [ "$(uname -s)" = "Linux" ]; then
        sudo chmod -R 755 themes/$THEME_NAME
    fi
}

# ... [保持原有参数处理、依赖检查、仓库同步逻辑不变] ...

# 修改后的初始化主题子模块部分 <== 替换原有逻辑
echo -e "\n${GREEN}🎨 初始化主题配置...${NC}"
if [ -d "themes/$THEME_NAME" ]; then
    echo -e "${YELLOW}✅ 主题已存在，正在验证完整性...${NC}"
    if [ ! -f "themes/$THEME_NAME/layout/index.ejs" ]; then
        echo -e "${RED}⚠️  检测到损坏的主题安装，重新初始化...${NC}"
        install_theme
    fi
else
    install_theme
fi

# 新增主题配置校验 <== 新增关键检查
echo -e "\n${GREEN}🔍 校验主题配置...${NC}"
if ! grep -q "theme: $THEME_NAME" _config.yml; then
    echo -e "${YELLOW}⚠️  正在自动配置主题参数...${NC}"
    sed -i.bak "s/theme:.*/theme: $THEME_NAME/" _config.yml
fi

# ... [保持原有 npm 依赖安装逻辑不变] ...

# 修改后的完成信息 <== 增加主题管理提示
echo -e "\n${GREEN}🎉 环境初始化完成！${NC}"
echo -e "主题管理命令："
echo -e "  更新主题: git submodule update --remote"
echo -e "  回滚主题: cd themes/$THEME_NAME && git checkout HEAD~1"

# 安全提醒（增加主题修改警告）
echo -e "\n${YELLOW}⚠️  主题开发提示："
echo -e "1. 修改主题请提交到子模块仓库"
echo -e "2. 避免直接修改 themes/$THEME_NAME 目录的文件"
echo -e "3. 建议 fork 主题仓库进行自定义${NC}"
