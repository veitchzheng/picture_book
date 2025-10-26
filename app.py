#!/usr/bin/env python3
"""
PDF裁剪Web界面
提供文件上传和下载功能
"""

from flask import Flask, render_template, request, send_file, redirect, url_for, flash
import os
import uuid
from werkzeug.utils import secure_filename
from pdf_cropper import PDFCropper

app = Flask(__name__)
app.secret_key = 'your-secret-key-here'
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['PROCESSED_FOLDER'] = 'processed'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB限制

# 允许的文件扩展名
ALLOWED_EXTENSIONS = {'pdf'}

def allowed_file(filename):
    """检查文件扩展名是否允许"""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def ensure_directories():
    """确保必要的目录存在"""
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    os.makedirs(app.config['PROCESSED_FOLDER'], exist_ok=True)

@app.route('/')
def index():
    """主页"""
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    """处理文件上传"""
    ensure_directories()
    
    if 'file' not in request.files:
        flash('请选择文件')
        return redirect(request.url)
    
    file = request.files['file']
    
    if file.filename == '':
        flash('请选择文件')
        return redirect(request.url)
    
    if file and allowed_file(file.filename):
        # 生成唯一文件名
        file_id = str(uuid.uuid4())
        original_filename = secure_filename(file.filename)
        input_filename = f"{file_id}_{original_filename}"
        output_filename = f"cropped_{file_id}_{original_filename}"
        
        input_path = os.path.join(app.config['UPLOAD_FOLDER'], input_filename)
        output_path = os.path.join(app.config['PROCESSED_FOLDER'], output_filename)
        
        # 保存上传的文件
        file.save(input_path)
        
        try:
            # 获取旋转选项（默认为True）
            rotate_covers = request.form.get('rotate_covers', 'true').lower() == 'true'
            
            # 处理PDF
            cropper = PDFCropper(input_path, rotate_covers=rotate_covers)
            cropper.process_pdf()
            cropper.save_output(output_path)
            
            # 返回下载链接
            return render_template('result.html', 
                                 download_url=url_for('download_file', filename=output_filename),
                                 original_name=original_filename)
            
        except Exception as e:
            flash(f'处理失败: {str(e)}')
            # 清理文件
            if os.path.exists(input_path):
                os.remove(input_path)
            return redirect(url_for('index'))
    else:
        flash('只支持PDF文件')
        return redirect(url_for('index'))

@app.route('/download/<filename>')
def download_file(filename):
    """提供文件下载"""
    file_path = os.path.join(app.config['PROCESSED_FOLDER'], filename)
    
    if os.path.exists(file_path):
        # 设置下载文件名
        download_name = filename.replace('cropped_', '')
        return send_file(file_path, 
                        as_attachment=True, 
                        download_name=download_name)
    else:
        flash('文件不存在')
        return redirect(url_for('index'))

@app.route('/cleanup', methods=['POST'])
def cleanup_files():
    """清理临时文件"""
    try:
        # 清理上传文件夹
        for filename in os.listdir(app.config['UPLOAD_FOLDER']):
            file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            if os.path.isfile(file_path):
                os.remove(file_path)
        
        # 清理处理文件夹
        for filename in os.listdir(app.config['PROCESSED_FOLDER']):
            file_path = os.path.join(app.config['PROCESSED_FOLDER'], filename)
            if os.path.isfile(file_path):
                os.remove(file_path)
        
        flash('临时文件已清理')
    except Exception as e:
        flash(f'清理失败: {str(e)}')
    
    return redirect(url_for('index'))

if __name__ == '__main__':
    ensure_directories()
    app.run(debug=True, host='0.0.0.0', port=5001)