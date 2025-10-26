# PDF小册子裁剪工具

一个用于PDF小册子打印准备的Web工具，支持智能裁剪和页面方向调整。

## 功能特性

- 📄 **封面封底处理**：第一页和最后一页作为封面封底（可选择是否转为纵版）
- ✂️ **正文裁剪**：横版双页排版自动裁剪为两页
- 🔄 **智能排序**：按正确顺序输出新PDF
- 🌐 **Web界面**：友好的用户界面，支持拖拽上传
- ⚙️ **灵活选项**：可控制封面封底旋转行为

## 快速开始

### 方法一：使用启动脚本（推荐）

#### Windows用户
支持多种命令：
```cmd
# 启动服务（默认）
start_windows.bat
start_windows.bat start

# 停止服务
start_windows.bat stop

# 重启服务
start_windows.bat restart

# 查看服务状态
start_windows.bat status

# 显示帮助
start_windows.bat help
```

#### Linux/macOS用户
支持多种命令：
```bash
# 给脚本添加执行权限
chmod +x start.sh

# 启动服务（默认）
./start.sh
./start.sh start

# 停止服务
./start.sh stop

# 重启服务
./start.sh restart

# 查看服务状态
./start.sh status

# 显示帮助
./start.sh help
```

### 方法二：手动启动

1. 安装依赖：
```bash
pip install -r requirements.txt
```

2. 启动应用：
```bash
python app.py
```

3. 访问 http://localhost:5001

## 使用方法

1. **选择PDF文件**：点击上传区域或拖拽PDF文件到指定区域
2. **设置选项**：根据需要选择是否将封面封底转为纵版
   - ✅ 勾选：封面封底如果是横版，会转为纵版（默认）
   - ❌ 取消：保持封面封底原有方向不变
3. **开始处理**：点击"开始处理"按钮
4. **下载结果**：处理完成后下载裁剪后的PDF文件

## 技术栈

- **后端**：Python Flask
- **PDF处理**：PyPDF2
- **前端**：HTML5, CSS3, JavaScript
- **文件处理**：Werkzeug

## 项目结构

```
picture_book/
├── app.py                 # Flask主应用
├── pdf_cropper.py         # PDF裁剪核心逻辑
├── requirements.txt       # Python依赖
├── start.sh              # Linux/macOS启动脚本
├── start_windows.bat     # Windows启动脚本
├── test_windows_logic.py # Windows脚本测试
├── README.md             # 项目说明
├── uploads/              # 上传文件临时目录
├── processed/            # 处理结果文件目录
└── templates/            # HTML模板
    ├── index.html        # 主页面
    └── result.html       # 结果页面
```

## 注意事项

- 确保系统已安装Python 3.7或更高版本
- PDF文件大小限制为16MB
- 处理过程中请勿关闭浏览器窗口
- 使用后可通过"清理临时文件"按钮清理生成的文件

## 故障排除

### 端口占用问题
如果端口5001被占用，可以修改app.py中的端口号：
```python
app.run(debug=True, host='0.0.0.0', port=新的端口号)
```

### 依赖安装失败
如果自动安装依赖失败，可以手动安装：
```bash
pip install Flask==2.3.3 PyPDF2==3.0.1 Werkzeug==2.3.7
```

### 文件权限问题（Linux/macOS）
确保脚本有执行权限：
```bash
chmod +x start.sh
```