//
//  VMKDebugServerBase64String.h
//  VeritasMachineKit
//
//  Created by tearsofphoenix on 13-2-28.
//
//

#ifndef __VMK_VMKDebugServerBase64String__
#define __VMK_VMKDebugServerBase64String__ 1

#define VMKDebugServerBase64String @"PGh0bWw+CjxoZWFkPgogICAgPG1ldGEgaHR0cC1lcXVpdj0iQ29udGVudC1UeXBlIiBjb250ZW50PSJ0ZXh0L2h0bWw7Y2hhcnNldD1VVEYtOCI+CiAgICA8dGl0bGU+V2ViIHNvY2tldHMgdGVzdDwvdGl0bGU+CiA8c3R5bGUgdHlwZT0idGV4dC9jc3MiPgogICAgIC5jb250YWluZXIKICAgICB7CiAgICAgICAgIGZvbnQtZmFtaWx5OiAiQ291cmllciBOZXciOwogICAgICAgICB3aWR0aDogNjgwcHg7CiAgICAgICAgIGhlaWdodDogMzAwcHg7CiAgICAgICAgIG92ZXJmbG93OiBhdXRvOwogICAgICAgICBib3JkZXI6IDFweCBzb2xpZCBibGFjazsKICAgICB9CgogICAgIC5Mb2NrT2ZmIHsKICAgICAgICAgZGlzcGxheTogbm9uZTsgCiAgICAgICAgIHZpc2liaWxpdHk6IGhpZGRlbjsgCiAgICAgIH0gCgogICAgICAuTG9ja09uIHsgCiAgICAgICAgIGRpc3BsYXk6IGJsb2NrOyAKICAgICAgICAgdmlzaWJpbGl0eTogdmlzaWJsZTsgCiAgICAgICAgIHBvc2l0aW9uOiBhYnNvbHV0ZTsgCiAgICAgICAgIHotaW5kZXg6IDk5OTsgCiAgICAgICAgIHRvcDogMHB4OyAKICAgICAgICAgbGVmdDogMHB4OyAKICAgICAgICAgd2lkdGg6IDEwMjQlOyAKICAgICAgICAgaGVpZ2h0OiA3NjglOyAKICAgICAgICAgYmFja2dyb3VuZC1jb2xvcjogI2NjYzsgCiAgICAgICAgIHRleHQtYWxpZ246IGNlbnRlcjsgCiAgICAgICAgIHBhZGRpbmctdG9wOiAyMCU7IAogICAgICAgICBmaWx0ZXI6IGFscGhhKG9wYWNpdHk9NzUpOyAKICAgICAgICAgb3BhY2l0eTogMC43NTsgCiAgICAgIH0gCiAgIDwvc3R5bGU+IAoKICAgIDxzY3JpcHQgc3JjPSJqcXVlcnktbWluLmpzIiB0eXBlPSJ0ZXh0L2phdmFzY3JpcHQiPjwvc2NyaXB0PgogICAgPHNjcmlwdCB0eXBlPSJ0ZXh0L2phdmFzY3JpcHQiPgogICAgICB2YXIgd3M7CiAgICAgIHZhciBTb2NrZXRDcmVhdGVkID0gZmFsc2U7CiAgICAgIHZhciBpc1VzZXJsb2dnZWRvdXQgPSBmYWxzZTsKCiAgICAgIGZ1bmN0aW9uIGxvY2tPbihzdHIpIAogICAgICB7IAogICAgICAgICB2YXIgbG9jayA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCdza21fTG9ja1BhbmUnKTsgCiAgICAgICAgIGlmIChsb2NrKSAKICAgICAgICAgICAgbG9jay5jbGFzc05hbWUgPSAnTG9ja09uJzsgCiAgICAgICAgIGxvY2suaW5uZXJIVE1MID0gc3RyOyAKICAgICAgfSAKCiAgICAgIGZ1bmN0aW9uIGxvY2tPZmYoKQogICAgICB7CiAgICAgICAgIHZhciBsb2NrID0gZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoJ3NrbV9Mb2NrUGFuZScpOyAKICAgICAgICAgbG9jay5jbGFzc05hbWUgPSAnTG9ja09mZic7IAogICAgICB9CgogICAgICBmdW5jdGlvbiBUb2dnbGVDb25uZWN0aW9uQ2xpY2tlZCgpCiAgICAgICAgewogICAgICAgICAgICBpZiAoU29ja2V0Q3JlYXRlZCAmJiAod3MucmVhZHlTdGF0ZSA9PSAwIHx8IHdzLnJlYWR5U3RhdGUgPT0gMSkpCiAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgIGxvY2tPbigi56a75byA6IGK5aSp5a6kLi4uIik7ICAKICAgICAgICAgICAgICAgIFNvY2tldENyZWF0ZWQgPSBmYWxzZTsKICAgICAgICAgICAgICAgIGlzVXNlcmxvZ2dlZG91dCA9IHRydWU7CiAgICAgICAgICAgICAgICB3cy5jbG9zZSgpOwogICAgICAgICAgICAgICAgCiAgICAgICAgICAgIH0gZWxzZQogICAgICAgICAgICB7CiAgICAgICAgICAgICAgICBsb2NrT24oIui/m+WFpeiBiuWkqeWupC4uLiIpOyAgCiAgICAgICAgICAgICAgICBMb2coIuWHhuWkh+i/nuaOpeWIsOiBiuWkqeacjeWKoeWZqCAuLi4iKTsKICAgICAgICAgICAgICAgIHRyeQogICAgICAgICAgICAgICAgewogICAgICAgICAgICAgICAgICAgIGlmICgiV2ViU29ja2V0IiBpbiB3aW5kb3cpCiAgICAgICAgICAgICAgICAgICAgewogICAgICAgICAgICAgICAgICAgIAl3cyA9IG5ldyBXZWJTb2NrZXQoImh0dHA6Ly8iICsgZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoIkNvbm5lY3Rpb24iKS52YWx1ZSk7CiAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgIH1lbHNlIGlmKCJNb3pXZWJTb2NrZXQiIGluIHdpbmRvdykKICAgICAgICAgICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAgICAgCXdzID0gbmV3IE1veldlYlNvY2tldCgiaHR0cDovLyIgKyBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgiQ29ubmVjdGlvbiIpLnZhbHVlKTsKICAgICAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgU29ja2V0Q3JlYXRlZCA9IHRydWU7CiAgICAgICAgICAgICAgICAgICAgaXNVc2VybG9nZ2Vkb3V0ID0gZmFsc2U7CiAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICB9IGNhdGNoIChleCkKICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICBMb2coZXgsICJFUlJPUiIpOwogICAgICAgICAgICAgICAgICAgIHJldHVybjsKICAgICAgICAgICAgICAgIH0KICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoIlRvZ2dsZUNvbm5lY3Rpb24iKS5pbm5lckhUTUwgPSAi5pat5byAIjsKICAgICAgICAgICAgICAgIHdzLm9ub3BlbiA9IFdTb25PcGVuOwogICAgICAgICAgICAgICAgd3Mub25tZXNzYWdlID0gV1Nvbk1lc3NhZ2U7CiAgICAgICAgICAgICAgICB3cy5vbmNsb3NlID0gV1NvbkNsb3NlOwogICAgICAgICAgICAgICAgd3Mub25lcnJvciA9IFdTb25FcnJvcjsKICAgICAgICAgICAgfQogICAgICAgIH07CgoKICAgICAgICBmdW5jdGlvbiBXU29uT3BlbigpCiAgICAgICAgewogICAgICAgICAgICBsb2NrT2ZmKCk7CiAgICAgICAgICAgIExvZygi6L+e5o6l5bey57uP5bu656uL44CCIiwgIk9LIik7CiAgICAgICAgICAgICQoIiNTZW5kRGF0YUNvbnRhaW5lciIpLnNob3coKTsKICAgCQkJICAgIHdzLnNlbmQoImxvZ2luOiIgKyBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgidHh0TmFtZSIpLnZhbHVlKTsKICAgICAgICB9OwoKICAgICAgICBmdW5jdGlvbiBXU29uTWVzc2FnZShldmVudCkKICAgICAgICB7CiAgICAgICAgICAgIExvZyhldmVudC5kYXRhKTsgICAgICAgICAgICAKICAgICAgICB9OwoKICAgICAgICBmdW5jdGlvbiBXU29uQ2xvc2UoKQogICAgICAgIHsKICAgICAgICAgICAgbG9ja09mZigpOwogICAgICAgICAgICBpZiAoaXNVc2VybG9nZ2Vkb3V0KQogICAgICAgICAgICAgICAgTG9nKCLjgJAiK2RvY3VtZW50LmdldEVsZW1lbnRCeUlkKCJ0eHROYW1lIikudmFsdWUrIuOAkeemu+W8gOS6huiBiuWkqeWupO+8gSIpOwogICAgICAgICAgICBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgiVG9nZ2xlQ29ubmVjdGlvbiIpLmlubmVySFRNTCA9ICLov57mjqUiOwogICAgICAgICAgICAkKCIjU2VuZERhdGFDb250YWluZXIiKS5oaWRlKCk7CiAgICAgICAgfTsKCiAgICAgICAgZnVuY3Rpb24gV1NvbkVycm9yKCkKICAgICAgICB7CiAgICAgICAgICAgIGxvY2tPZmYoKTsKICAgICAgICAgICAgTG9nKCLov5znqIvov57mjqXkuK3mlq3jgIIiLCAiRVJST1IiKTsKICAgICAgICB9OwoKCiAgICAgICAgZnVuY3Rpb24gU2VuZERhdGFDbGlja2VkKCkKICAgICAgICB7CiAgICAgICAgICAgIHZhciBkYXRhID0gZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoIkRhdGFUb1NlbmQiKS52YWx1ZTsKICAgICAgICAgICAgaWYgKGRhdGEudHJpbSgpICE9ICIiKQogICAgICAgICAgICB7CiAgICAgICAgICAgICAgICB2YXIgcmVxdWVzdCA9IG5ldyBYTUxIdHRwUmVxdWVzdCgpOwogICAgICAgICAgICAgICAgcmVxdWVzdC5vcGVuKCJHRVQiLCAiaHR0cDovLzEyNy4wLjAuMTo5NDQ5L2NvbW1hbmQvIiArIGRhdGEsIHRydWUpOwogICAgICAgICAgICB9CiAgICAgICAgfTsKCgogICAgICAgIGZ1bmN0aW9uIExvZyhUZXh0LCBNZXNzYWdlVHlwZSkKICAgICAgICB7CiAgICAgICAgICAgIGlmIChNZXNzYWdlVHlwZSA9PSAiT0siKSBUZXh0ID0gIjxzcGFuIHN0eWxlPSdjb2xvcjogZ3JlZW47Jz4iICsgVGV4dCArICI8L3NwYW4+IjsKICAgICAgICAgICAgaWYgKE1lc3NhZ2VUeXBlID09ICJFUlJPUiIpIFRleHQgPSAiPHNwYW4gc3R5bGU9J2NvbG9yOiByZWQ7Jz4iICsgVGV4dCArICI8L3NwYW4+IjsKICAgICAgICAgICAgZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoIkxvZ0NvbnRhaW5lciIpLmlubmVySFRNTCA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCJMb2dDb250YWluZXIiKS5pbm5lckhUTUwgKyBUZXh0ICsgIjxiciAvPiI7CiAgICAgICAgICAgIHZhciBMb2dDb250YWluZXIgPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgiTG9nQ29udGFpbmVyIik7CiAgICAgICAgICAgIExvZ0NvbnRhaW5lci5zY3JvbGxUb3AgPSBMb2dDb250YWluZXIuc2Nyb2xsSGVpZ2h0OwogICAgICAgIH07CgoKICAgICAgICAkKGRvY3VtZW50KS5yZWFkeShmdW5jdGlvbiAoKQogICAgICAgICAgICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICQoIiNTZW5kRGF0YUNvbnRhaW5lciIpLmhpZGUoKTsKICAgICAgICAgICAgICAgICAgICAgICAgICAgIHZhciBXZWJTb2NrZXRzRXhpc3QgPSB0cnVlOwogICAgICAgICAgICAgICAgICAgICAgICAgIHRyeQogICAgICAgICAgICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgIHZhciBkdW1teSA9IG5ldyBXZWJTb2NrZXQoIndzOi8vMTI3LjAuMC4xOjk0NDkvdGVzdCIpOwogICAgICAgICAgICAgICAgICAgICAgICAgIH0gY2F0Y2ggKGV4KQogICAgICAgICAgICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgIHRyeQogICAgICAgICAgICAgICAgICAgICAgICAgICAgewogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHdlYlNvY2tldCA9IG5ldyBNb3pXZWJTb2NrZXQoIndzOi8vMTI3LjAuMC4xOjk0NDkvdGVzdCIpOwogICAgICAgICAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAgICAgICAgICAgICAgICAgICAgY2F0Y2goZXgpCiAgICAgICAgICAgICAgICAgICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgV2ViU29ja2V0c0V4aXN0ID0gZmFsc2U7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgICAgICAgICAgICAgICAgfQoKICAgICAgICAgICAgICAgICAgICAgICAgICBpZiAoV2ViU29ja2V0c0V4aXN0KQogICAgICAgICAgICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBMb2coIuaCqOeahOa1j+iniOWZqOaUr+aMgVdlYlNvY2tldC4g5oKo5Y+v5Lul5bCd6K+V6L+e5o6l5Yiw6IGK5aSp5pyN5Yqh5ZmoISIsICJPSyIpOwogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCJDb25uZWN0aW9uIikudmFsdWUgPSAiMTI3LjAuMC4xOjk0NDkvY2hhdCI7CiAgICAgICAgICAgICAgICAgICAgICAgICAgfSBlbHNlCiAgICAgICAgICAgICAgICAgICAgICAgICAgewogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIExvZygi5oKo55qE5rWP6KeI5Zmo5LiN5pSv5oyBV2ViU29ja2V044CC6K+36YCJ5oup5YW25LuW55qE5rWP6KeI5Zmo5YaN5bCd6K+V6L+e5o6l5pyN5Yqh5Zmo44CCIiwgIkVSUk9SIik7CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoIlRvZ2dsZUNvbm5lY3Rpb24iKS5kaXNhYmxlZCA9IHRydWU7CiAgICAgICAgICAgICAgICAgICAgICAgICAgfSAgICAKICAgICAgICAgICAgCiAgICAgICAgICAgICQoIiNEYXRhVG9TZW5kIikua2V5cHJlc3MoZnVuY3Rpb24oZXZ0KQogICAgICAgICAgICB7CiAgICAgICAgICAgIAkJaWYgKGV2dC5rZXlDb2RlID09IDEzKQogICAgICAgICAgICAJCXsKICAgICAgICAgICAgCQkJCSQoIiNTZW5kRGF0YSIpLmNsaWNrKCk7CiAgICAgICAgICAgIAkJCQlldnQucHJldmVudERlZmF1bHQoKTsKICAgICAgICAgICAgCQl9CiAgICAgICAgICAgIH0pICAgICAgICAKICAgICAgICB9KTsKCiAgICA8L3NjcmlwdD4KPC9oZWFkPgo8Ym9keT4KICAgIDxkaXYgaWQ9InNrbV9Mb2NrUGFuZSIgY2xhc3M9IkxvY2tPZmYiPjwvZGl2PgogICAgPGZvcm0gaWQ9ImZvcm0xIiBydW5hdD0ic2VydmVyIj4KICAgICAgICA8aDE+Vk1LRGVidWdDbGllbnQ8L2gxPgogICAgICAgIDxiciAvPlNlcnZlciBBZGRyZXNzIDxpbnB1dCB0eXBlPSJ0ZXh0IiBpZD0iQ29ubmVjdGlvbiIgLz5OYW1lOjxpbnB1dCB0eXBlPSJ0ZXh0IiBpZD0idHh0TmFtZSIvPgogICAgICAgIDxidXR0b24gaWQ9J1RvZ2dsZUNvbm5lY3Rpb24nIHR5cGU9ImJ1dHRvbiIgb25jbGljaz0nVG9nZ2xlQ29ubmVjdGlvbkNsaWNrZWQoKTsnPkNvbm5lY3Q8L2J1dHRvbj4KICAgICAgICA8YnIgLz4KICAgICAgICA8YnIgLz4KICAgICAgICA8ZGl2IGlkPSdMb2dDb250YWluZXInIGNsYXNzPSdjb250YWluZXInPjwvZGl2PgogICAgICAgIDxiciAvPgogICAgICAgIDxkaXYgaWQ9J1NlbmREYXRhQ29udGFpbmVyJz4KICAgICAgICA8aW5wdXQgdHlwZT0idGV4dCIgaWQ9IkRhdGFUb1NlbmQiIHNpemU9Ijg4IiAvPgogICAgICAgIDxidXR0b24gaWQ9J1NlbmREYXRhJyB0eXBlPSJidXR0b24iIG9uY2xpY2s9J1NlbmREYXRhQ2xpY2tlZCgpOyc+U2VuZDwvYnV0dG9uPgogICAgICAgIDwvZGl2PgogICAgICAgIDxiciAvPgogICAgPC9mb3JtPgo8L2JvZHk+CjwvaHRtbD4KCg=="

#endif