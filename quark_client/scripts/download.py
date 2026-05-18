import sys
from pathlib import Path

_project_root = Path(__file__).parent.parent.parent
if str(_project_root) not in sys.path:
    sys.path.insert(0, str(_project_root))

import requests
import json
from typing import Dict, Optional
from quark_client.exceptions import APIError
from quark_client.config import get_config_dir

def get_real_download_url(file_id: str) -> str:
    """获取真实下载链接"""
    
    params = {
        "pr": "ucpro",
        "fr": "pc",
        "uc_param_str": "",
    }
    cookies = None
    cookie_path = get_config_dir() / "cookies.json"
    if cookie_path.exists():
        try:
            with open(cookie_path, 'r') as f:
                data = json.load(f)
                if 'cookie_string' in data:
                    cookies = data['cookie_string']
                elif 'cookies' in data:
                    # 转换列表格式为字符串
                    cookie_list = data['cookies']
                    if isinstance(cookie_list, list):
                        cookies = "; ".join([f"{c['name']}={c['value']}" for c in cookie_list])
                    elif isinstance(cookie_list, dict):
                        cookies = "; ".join([f"{k}={v}" for k, v in cookie_list.items()])
            # if cookies:
            #     print("✅ Cookies 读取成功")
        except Exception as e:
            print(f"读取失败: {e}")
    print(cookies)
    headers: Dict[str, str] = {
        'User-Agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) quark-cloud-drive/2.5.20 Chrome/100.0.4896.160 Electron/18.3.5.4-b478491100 Safari/537.36 Channel/pckk_other_ch",
        'origin': 'https://pan.quark.cn',
        'referer': 'https://pan.quark.cn/',
        'accept-language': 'zh-CN,zh;q=0.9',
        'cookie': cookies,
    }

    data = {'fids': [file_id]}

    # 使用完整的API端点URL，绕过基础URL拼接
    response = requests.post(
        'https://drive-pc.quark.cn/1/clouddrive/file/download',
        json=data,
        params=params,
        headers=headers,
    )
    print(response.text)


    # 解析下载链接
    if isinstance(response, dict) and 'data' in response:
        data_list = response['data']
        if data_list and len(data_list) > 0:
            download_info = data_list[0]
            return download_info.get('download_url', '')

    raise APIError("无法获取下载链接")


if __name__ == '__main__':
    file_id = '35acdde9f25747bdbae3e5cac4154a62'
    download_url = get_real_download_url(file_id)
    print(download_url)