#!/usr/bin/env python3
"""
PDF裁剪工具 - 用于小册子打印准备
功能：
1. 裁剪PDF，第一页和最后一页作为封面
2. 封面转为纵版
3. 正文横版双页排版裁剪为两页
4. 按顺序输出新PDF
"""

import PyPDF2
from PyPDF2 import PdfReader, PdfWriter, Transformation
import math
import sys
import os

class PDFCropper:
    def __init__(self, input_pdf_path):
        self.input_pdf_path = input_pdf_path
        self.reader = PdfReader(input_pdf_path)
        self.writer = PdfWriter()
        
    def get_page_dimensions(self, page):
        """获取页面尺寸"""
        mediabox = page.mediabox
        width = float(mediabox.width)
        height = float(mediabox.height)
        return width, height
    
    def is_landscape(self, page):
        """判断页面是否为横版"""
        width, height = self.get_page_dimensions(page)
        return width > height
    
    def rotate_to_portrait(self, page):
        """将页面转为纵版"""
        if self.is_landscape(page):
            # 如果是横版，旋转90度转为纵版
            page.rotate(90)
        return page
    def crop_landscape_page(self, page):
        """对半裁剪横版页面"""
        import copy
        width, height = self.get_page_dimensions(page)
        
        # 创建左半页（深拷贝）
        left_page = copy.deepcopy(page)
        left_page.cropbox.upper_right = (width / 2, height)
        
        # 创建右半页（深拷贝）
        right_page = copy.deepcopy(page)
        right_page.cropbox.lower_left = (width / 2, 0)
        
        return [left_page, right_page]
        return [left_page, right_page]
    
    def process_pdf(self):
        """处理PDF文件"""
        total_pages = len(self.reader.pages)
        
        print(f"正在处理PDF: {self.input_pdf_path}")
        print(f"总页数: {total_pages}")
        
        if total_pages < 3:
            raise ValueError("PDF至少需要3页（封面+至少1页正文+封底）")
        
        # 处理封面（第一页）
        print("处理封面...")
        cover_page = self.reader.pages[0]
        cover_page = self.rotate_to_portrait(cover_page)
        self.writer.add_page(cover_page)
        
        # 处理正文页（中间所有页）
        print("处理正文页...")
        for i in range(1, total_pages - 1):
            page = self.reader.pages[i]
            
            if self.is_landscape(page):
                # 横版页面，直接对半裁剪
                cropped_pages = self.crop_landscape_page(page)
                for cropped_page in cropped_pages:
                    self.writer.add_page(cropped_page)
            else:
                # 纵版页面，直接添加
                self.writer.add_page(page)
        
        # 处理封底（最后一页）
        print("处理封底...")
        back_cover_page = self.reader.pages[total_pages - 1]
        back_cover_page = self.rotate_to_portrait(back_cover_page)
        self.writer.add_page(back_cover_page)
        
        print("PDF处理完成！")
    
    def save_output(self, output_path):
        """保存输出PDF"""
        with open(output_path, 'wb') as output_file:
            self.writer.write(output_file)
        print(f"输出文件已保存: {output_path}")

def main():
    if len(sys.argv) != 3:
        print("用法: python pdf_cropper.py <输入PDF路径> <输出PDF路径>")
        print("示例: python pdf_cropper.py input.pdf output.pdf")
        sys.exit(1)
    
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    
    if not os.path.exists(input_path):
        print(f"错误: 输入文件不存在: {input_path}")
        sys.exit(1)
    
    try:
        cropper = PDFCropper(input_path)
        cropper.process_pdf()
        cropper.save_output(output_path)
        print("PDF裁剪成功！")
    except Exception as e:
        print(f"处理失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()