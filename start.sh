#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 端口配置
PORT=5001
APP_NAME="PDF小册子裁剪工具"

# 显示帮助信息
show_help() {
    echo "用法: $0 [start|stop|restart|status]"
    echo ""
    echo "命令:"
    echo "  start    启动服务"
    echo "  stop     停止服务"
    echo "  restart  重启服务"
    echo "  status   查看服务状态"
    echo "  无参数   默认启动服务"
    echo ""
}

# 检查服务状态
check_status() {
    if lsof -i :$PORT > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $APP_NAME 正在运行 (端口 $PORT)${NC}"
        return 0
    else
        echo -e "${RED}✗ $APP_NAME 未运行${NC}"
        return 1
    fi
}

# 停止服务
stop_service() {
    echo -e "${YELLOW}正在停止 $APP_NAME...${NC}"
    
    # 首先尝试使用PID文件停止
    if [ -f "app.pid" ]; then
        APP_PID=$(cat app.pid)
        if ps -p $APP_PID > /dev/null 2>&1; then
            echo "找到进程PID: $APP_PID"
            kill $APP_PID
            sleep 2
            
            # 检查是否成功停止
            if ps -p $APP_PID > /dev/null 2>&1; then
                echo "强制终止进程..."
                kill -9 $APP_PID
            fi
            
            rm -f app.pid
            echo -e "${GREEN}✓ 服务已停止${NC}"
            return 0
        else
            rm -f app.pid
        fi
    fi
    
    # 如果PID文件不存在或无效，使用端口查找
    PIDS=$(lsof -ti :$PORT)
    if [ -n "$PIDS" ]; then
        echo "通过端口找到进程: $PIDS"
        kill $PIDS
        sleep 2
        
        # 强制杀死仍在运行的进程
        if lsof -ti :$PORT > /dev/null 2>&1; then
            echo "强制终止进程..."
            kill -9 $(lsof -ti :$PORT) 2>/dev/null
        fi
        
        rm -f app.pid
        echo -e "${GREEN}✓ 服务已停止${NC}"
    else
        echo -e "${YELLOW}⚠ 未找到运行中的服务${NC}"
    fi
}

# 启动服务
start_service() {
    echo "========================================"
    echo "   $APP_NAME - Linux/macOS启动脚本"
    echo "========================================"
    echo

    # 检查Python是否安装
    if ! command -v python3 &> /dev/null; then
        echo "错误: 未找到Python3，请先安装Python 3.7或更高版本"
        echo "Ubuntu/Debian: sudo apt install python3 python3-pip"
        echo "macOS: brew install python3"
        echo "CentOS/RHEL: sudo yum install python3 python3-pip"
        exit 1
    fi

    # 检查pip是否可用
    if ! python3 -m pip --version &> /dev/null; then
        echo "错误: pip不可用，请确保Python安装正确"
        exit 1
    fi

    echo "正在检查依赖包..."
    echo

    # 检查并安装Flask
    if ! python3 -c "import flask" &> /dev/null; then
        echo "安装Flask..."
        python3 -m pip install Flask==2.3.3
        if [ $? -ne 0 ]; then
            echo "错误: Flask安装失败"
            exit 1
        fi
    else
        echo "✓ Flask已安装"
    fi

    # 检查并安装PyPDF2
    if ! python3 -c "import PyPDF2" &> /dev/null; then
        echo "安装PyPDF2..."
        python3 -m pip install PyPDF2==3.0.1
        if [ $? -ne 0 ]; then
            echo "错误: PyPDF2安装失败"
            exit 1
        fi
    else
        echo "✓ PyPDF2已安装"
    fi

    # 检查并安装Werkzeug
    if ! python3 -c "import werkzeug" &> /dev/null; then
        echo "安装Werkzeug..."
        python3 -m pip install Werkzeug==2.3.7
        if [ $? -ne 0 ]; then
            echo "错误: Werkzeug安装失败"
            exit 1
        fi
    else
        echo "✓ Werkzeug已安装"
    fi

    echo
    echo "========================================"
    echo "          依赖检查完成！"
    echo "========================================"
    echo

    # 创建必要的目录
    mkdir -p uploads processed

    echo "正在启动PDF小册子裁剪工具..."
    echo
    echo "访问地址: http://localhost:$PORT"
    echo "使用 '$0 stop' 停止服务"
    echo

    # 启动Flask应用（后台执行）
    nohup python3 app.py > app.log 2>&1 &
    APP_PID=$!
    echo $APP_PID > app.pid
    echo -e "${GREEN}✓ 服务已启动 (PID: $APP_PID)${NC}"
    echo -e "${BLUE}日志文件: app.log${NC}"
}

# 重启服务
restart_service() {
    stop_service
    sleep 2
    start_service
}

# 主逻辑
case "${1:-start}" in
    "start")
        if check_status; then
            echo -e "${YELLOW}⚠ 服务已在运行，如需重启请使用: $0 restart${NC}"
        else
            start_service
        fi
        ;;
    "stop")
        stop_service
        ;;
    "restart")
        restart_service
        ;;
    "status")
        check_status
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "未知命令: $1"
        show_help
        exit 1
        ;;
esac