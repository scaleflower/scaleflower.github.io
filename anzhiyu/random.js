var posts=["2025/03/25/低代码编程，恐怕不会成功/","2025/03/20/Test-pages/"];function toRandomPost(){
    pjax.loadUrl('/'+posts[Math.floor(Math.random() * posts.length)]);
  };