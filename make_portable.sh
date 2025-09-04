#!/bin/bash
#
# 让项目可以 Download ZIP 后直接运行的脚本
# Make project portable - can run directly after Download ZIP
#

echo "🚀 开始配置可移植项目 / Starting portable project setup..."

# 1. 创建 Libraries 目录存放所有依赖
echo "📁 创建 Libraries 目录 / Creating Libraries directory..."
mkdir -p Libraries

# 2. 复制所有已下载的依赖
echo "📦 复制依赖包 / Copying dependencies..."
if [ -d ".build/checkouts" ]; then
    cp -R .build/checkouts/* Libraries/
    echo "✅ 已复制所有依赖 / All dependencies copied"
    
    # 3. 删除不必要的文件以减小体积
    echo "🧹 清理不必要的文件 / Cleaning unnecessary files..."
    find Libraries -name ".git" -type d -exec rm -rf {} + 2>/dev/null
    find Libraries -name ".github" -type d -exec rm -rf {} + 2>/dev/null
    find Libraries -name "Tests" -type d -exec rm -rf {} + 2>/dev/null
    find Libraries -name "*.md" -type f -delete 2>/dev/null
    find Libraries -name ".gitignore" -type f -delete 2>/dev/null
    echo "✅ 清理完成 / Cleanup complete"
else
    echo "⚠️ 请先运行 'swift package resolve' 下载依赖"
    exit 1
fi

# 4. 检查文件大小
echo ""
echo "📊 依赖包大小 / Dependencies size:"
du -sh Libraries/* | sort -h

# 5. 创建说明文件
cat > Libraries/README.txt << 'EOF'
这些是项目的本地依赖包 / These are local dependency packages
无需额外下载 / No additional downloads required
直接打开 Xcode 项目即可运行 / Just open the Xcode project and run
EOF

echo ""
echo "✅ 完成！/ Complete!"
echo ""
echo "📝 下一步 / Next steps:"
echo "1. 在 Xcode 中打开项目 / Open project in Xcode"
echo "2. 移除远程包依赖 / Remove remote package dependencies:"
echo "   - File > Packages > Reset Package Caches"
echo "   - 删除 Package Dependencies / Remove Package Dependencies"
echo "3. 添加本地包依赖 / Add local package dependencies:"
echo "   - File > Add Package Dependencies > Add Local"
echo "   - 选择 Libraries/swift-composable-architecture"
echo "4. 提交到 Git / Commit to Git:"
echo "   git add Libraries/"
echo "   git commit -m 'Add local dependencies for portable project'"
echo "5. 推送到 GitHub / Push to GitHub"
echo ""
echo "🎉 其他人使用时 / For other users:"
echo "   1. GitHub 网页 > Code > Download ZIP"
echo "   2. 解压 / Unzip"
echo "   3. 打开 .xcodeproj / Open .xcodeproj"
echo "   4. 直接运行！/ Just run!"