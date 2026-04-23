/**
 * Element-tree templates for og:images. Satori CSS is a subset of real CSS:
 * containers with multiple children must use display: flex.
 *
 * Each template is a function: (data) => element tree.
 */

const FONT_FAMILY = "Faire Sprig Sans";
const MONO_FAMILY = "Maple Mono";

// Brand accent colour per org, used for the top border strip and the wiggle
// underline.
const ACCENTS = {
  hanakai: "#FFD33B",
  hanami: "#FF6C89",
  dry: "#FF8000",
  rom: "#0063FF",
};

const INNER_BG = "#ffffff";
const TEXT = "#1A1A1A";
const TEXT_MUTED = "#393939";

const URL_LABEL = "hanakai.org";

// Layout constants. The outer canvas takes the brand accent colour as a
// border, the inner rounded box holds all content. Inner content width
// (= WIGGLE_WIDTH) is derived so the squiggle lines up with the body padding.
const CANVAS_W = 1024;
const OUTER_PAD = 16;
const INNER_PAD_X = 60;
const INNER_RADIUS = 24;
const CONTENT_W = CANVAS_W - 2 * OUTER_PAD - 2 * INNER_PAD_X;

// SVG marks lifted from app/templates/svgs/_*_logo_static.html.erb. Inlined as
// data URIs so Satori can render them via <img src>.
const LOGO_SVGS = {
  hanakai: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 216 216" fill="none"><path d="M108.094 183.847C149.982 183.847 183.94 149.89 183.94 108.001C183.94 66.1126 149.982 32.1553 108.094 32.1553C66.2055 32.1553 32.248 66.1126 32.248 108.001C32.248 149.89 66.2055 183.847 108.094 183.847Z" fill="#FFD33B"/><path d="M60.5458 112.389C64.0084 112.389 66.8153 109.582 66.8153 106.119C66.8153 102.657 64.0084 99.8496 60.5458 99.8496C57.0833 99.8496 54.2764 102.657 54.2764 106.119C54.2764 109.582 57.0833 112.389 60.5458 112.389Z" fill="#FFEA89"/><path d="M155.634 112.389C159.096 112.389 161.903 109.582 161.903 106.119C161.903 102.657 159.096 99.8496 155.634 99.8496C152.171 99.8496 149.364 102.657 149.364 106.119C149.364 109.582 152.171 112.389 155.634 112.389Z" fill="#FFEA89"/><path d="M82.7644 100.528C87.1675 100.528 90.7369 96.9585 90.7369 92.5554C90.7369 88.1524 87.1675 84.583 82.7644 84.583C78.3614 84.583 74.792 88.1524 74.792 92.5554C74.792 96.9585 78.3614 100.528 82.7644 100.528Z" fill="black"/><path d="M133.414 100.528C137.817 100.528 141.386 96.9585 141.386 92.5554C141.386 88.1524 137.817 84.583 133.414 84.583C129.011 84.583 125.441 88.1524 125.441 92.5554C125.441 96.9585 129.011 100.528 133.414 100.528Z" fill="black"/><path fill-rule="evenodd" clip-rule="evenodd" d="M125.677 115.435C126.677 113.473 129.088 112.695 131.05 113.699C133.011 114.7 133.789 117.11 132.785 119.072C128.263 127.919 119.057 133.979 108.445 133.979C97.1313 133.979 87.4208 127.094 83.2708 117.29C82.4117 115.259 83.3605 112.917 85.3907 112.058C87.4208 111.199 89.7672 112.148 90.6263 114.178C93.5625 121.119 100.435 125.996 108.445 125.996C115.954 125.996 122.472 121.7 125.677 115.435Z" fill="black"/><path fill-rule="evenodd" clip-rule="evenodd" d="M109.27 0.0117188C112.826 0.0117188 115.705 2.90545 115.705 6.45546V20.1539C115.705 23.7039 112.826 26.5984 109.27 26.5984H106.73C103.174 26.5984 100.295 23.7039 100.295 20.1539C100.295 15.9865 100.295 10.5843 100.295 6.45546C100.295 2.90545 103.174 0.0117188 106.73 0.0117188H109.27Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M67.8515 7.74309C71.137 6.38221 74.9041 7.95397 76.2627 11.2338C77.8427 15.0483 79.91 20.0393 81.5048 23.8895C82.8633 27.1692 81.3113 30.9451 78.0258 32.306L75.679 33.278C72.3936 34.6389 68.6262 33.0665 67.2676 29.7867C65.6728 25.9365 63.6055 20.9455 62.0255 17.131C60.667 13.8512 62.2193 10.076 65.5048 8.71515L67.8515 7.74309Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M32.5437 30.7249C35.0583 28.2103 39.1401 28.2208 41.6503 30.731L51.3366 40.4173C53.8468 42.9275 53.8578 47.0099 51.3432 49.5245L49.5471 51.3206C47.0325 53.8352 42.9501 53.8242 40.4399 51.3139L30.7537 41.6277C28.2434 39.1175 28.2329 35.0356 30.7475 32.521L32.5437 30.7249Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M8.7237 65.4844C10.0846 62.1989 13.8597 60.6466 17.1395 62.0051L29.7952 67.2473C33.075 68.6058 34.6475 72.3732 33.2866 75.6587L32.3145 78.0054C30.9537 81.2909 27.1778 82.843 23.898 81.4844L11.2423 76.2423C7.96252 74.8837 6.39076 71.1166 7.75164 67.8312L8.7237 65.4844Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M0.0117188 106.727C0.0117188 103.171 2.90545 100.292 6.45546 100.292H20.1539C23.7039 100.292 26.5984 103.171 26.5984 106.727V109.267C26.5984 112.823 23.7039 115.702 20.1539 115.702H6.45546C2.90545 115.702 0.0117188 112.823 0.0117188 109.267C0.0117188 108.42 0.0117188 107.574 0.0117188 106.727Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M7.74309 148.146C6.38221 144.86 7.95397 141.093 11.2338 139.734L23.8895 134.492C27.1692 133.134 30.9451 134.686 32.306 137.971C32.63 138.754 32.954 139.536 33.278 140.318C34.6389 143.603 33.0665 147.371 29.7867 148.729L17.131 153.972C13.8512 155.33 10.076 153.778 8.71515 150.492C8.39113 149.71 8.06711 148.928 7.74309 148.146Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M30.7249 183.453C28.2103 180.939 28.2208 176.857 30.731 174.347C33.6505 171.427 37.4705 167.607 40.4173 164.661C42.9275 162.15 47.0099 162.139 49.5245 164.654L51.3206 166.45C53.8352 168.965 53.8242 173.047 51.3139 175.557L41.6277 185.243C39.1175 187.754 35.0356 187.764 32.521 185.25L30.7249 183.453Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M65.4834 207.273C62.198 205.912 60.6456 202.137 62.0041 198.858L67.2463 186.202C68.6048 182.922 72.3722 181.35 75.6577 182.71L78.0044 183.683C81.2899 185.043 82.842 188.819 81.4835 192.099L76.2413 204.755C74.8828 208.035 71.1157 209.606 67.8302 208.245L65.4834 207.273Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M106.727 215.985C103.171 215.985 100.292 213.092 100.292 209.542C100.292 205.413 100.292 200.011 100.292 195.843C100.292 192.293 103.171 189.399 106.727 189.399H109.267C112.823 189.399 115.702 192.293 115.702 195.843V209.542C115.702 213.092 112.823 215.985 109.267 215.985H106.727Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M148.146 208.255C144.86 209.616 141.093 208.044 139.734 204.764L134.492 192.109C133.134 188.829 134.686 185.053 137.971 183.692L140.318 182.72C143.603 181.359 147.371 182.932 148.729 186.211L153.972 198.867C155.33 202.147 153.778 205.922 150.492 207.283L148.146 208.255Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M183.453 185.267C180.939 187.782 176.857 187.771 174.347 185.261C171.427 182.342 167.607 178.522 164.661 175.575C162.15 173.065 162.139 168.982 164.654 166.468L166.45 164.672C168.965 162.157 173.047 162.168 175.557 164.678L185.243 174.364C187.754 176.875 187.764 180.957 185.25 183.471C184.651 184.07 184.052 184.669 183.453 185.267Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M207.273 150.509C205.912 153.794 202.137 155.347 198.858 153.988L186.202 148.746C182.922 147.387 181.35 143.62 182.71 140.335L183.683 137.988C185.043 134.702 188.819 133.15 192.099 134.509L204.755 139.751C208.035 141.109 209.606 144.877 208.245 148.162L207.273 150.509Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M215.985 109.271C215.985 112.827 213.092 115.706 209.542 115.706L195.843 115.706C192.293 115.706 189.399 112.827 189.399 109.271V106.731C189.399 103.175 192.293 100.296 195.843 100.296L209.542 100.296C213.092 100.296 215.985 103.175 215.985 106.731V109.271Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M208.254 67.8525C209.615 71.138 208.043 74.9051 204.763 76.2636C200.949 77.8437 195.958 79.911 192.108 81.5058C188.828 82.8643 185.052 81.3122 183.691 78.0268L182.719 75.68C181.358 72.3945 182.931 68.6271 186.21 67.2686L198.866 62.0265C202.146 60.6679 205.921 62.2203 207.282 65.5058L208.254 67.8525Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M185.266 32.5437C187.781 35.0583 187.77 39.1401 185.26 41.6503L175.574 51.3366C173.064 53.8468 168.981 53.8578 166.467 51.3432L164.671 49.5471C162.156 47.0325 162.167 42.9501 164.677 40.4399L174.364 30.7537C176.874 28.2434 180.956 28.2329 183.47 30.7475L185.266 32.5437Z" fill="#FFD33B"/><path fill-rule="evenodd" clip-rule="evenodd" d="M150.508 8.7237C153.793 10.0846 155.346 13.8597 153.987 17.1395L148.745 29.7952C147.386 33.075 143.619 34.6475 140.334 33.2866L137.987 32.3145C134.701 30.9537 133.149 27.1778 134.508 23.898L139.75 11.2423C141.108 7.96252 144.876 6.39076 148.161 7.75164L150.508 8.7237Z" fill="#FFD33B"/></svg>`,
  hanami: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 201 194" fill="none"><path fill-rule="evenodd" clip-rule="evenodd" d="M48.183 120.394C43.5169 120.84 38.6886 120.362 33.9543 118.828L24.3575 115.723C5.864 109.736 -4.27507 89.9154 1.73574 71.4882C7.74227 53.0631 27.636 42.9638 46.1337 48.9512L55.7305 52.0564C60.4649 53.5899 64.6529 56.0303 68.162 59.1227C66.2964 54.843 65.2591 50.1194 65.2591 45.1579V35.1053C65.2591 15.7308 81.0503 0.000976562 100.496 0.000976562C119.941 0.000976562 135.728 15.7308 135.728 35.1053V45.1579C135.728 50.1194 134.695 54.843 132.825 59.1227C136.334 56.0303 140.522 53.5899 145.261 52.0564L154.858 48.9512C173.351 42.9638 193.245 53.0631 199.256 71.4882C205.266 89.9154 195.127 109.736 176.634 115.723L167.037 118.828C162.299 120.362 157.47 120.84 152.809 120.394C156.843 122.764 160.467 125.978 163.396 129.994L169.326 138.126C180.758 153.801 177.266 175.771 161.53 187.16C145.799 198.548 123.749 195.069 112.317 179.395L106.387 171.26C103.458 167.246 101.512 162.819 100.496 158.261C99.4798 162.819 97.533 167.246 94.6044 171.26L88.6749 179.395C77.2424 195.069 55.1885 198.548 39.4571 187.16C23.7257 175.771 20.2335 153.801 31.6617 138.126L37.5957 129.994C40.5199 125.978 44.1445 122.764 48.183 120.394Z" fill="#FF6C89"/><path d="M100.491 147.191C125.435 147.191 145.656 127.044 145.656 102.192C145.656 77.3407 125.435 57.1943 100.491 57.1943C75.5472 57.1943 55.3262 77.3407 55.3262 102.192C55.3262 127.044 75.5472 147.191 100.491 147.191Z" fill="#FFC9C4"/><path fill-rule="evenodd" clip-rule="evenodd" d="M78.1884 101.341C78.1884 103.219 76.6571 104.744 74.7723 104.744C72.8858 104.744 71.3562 103.219 71.3562 101.341C71.3562 94.5937 76.8534 89.1152 83.6255 89.1152C90.3977 89.1152 95.8965 94.5937 95.8965 101.341C95.8965 103.219 94.3653 104.744 92.4804 104.744C90.5956 104.744 89.0643 103.219 89.0643 101.341C89.0643 98.3495 86.628 95.9222 83.6255 95.9222C80.6247 95.9222 78.1884 98.3495 78.1884 101.341Z" fill="black"/><path fill-rule="evenodd" clip-rule="evenodd" d="M112.006 101.341C112.006 103.219 110.474 104.744 108.59 104.744C106.703 104.744 105.174 103.219 105.174 101.341C105.174 94.5937 110.671 89.1152 117.443 89.1152C124.215 89.1152 129.714 94.5937 129.714 101.341C129.714 103.219 128.183 104.744 126.298 104.744C124.413 104.744 122.882 103.219 122.882 101.341C122.882 98.3495 120.445 95.9222 117.443 95.9222C114.442 95.9222 112.006 98.3495 112.006 101.341Z" fill="black"/></svg>`,
  dry: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 201 201" fill="none"><path fill-rule="evenodd" clip-rule="evenodd" d="M41.6335 124.778H24.3448C10.9062 124.778 -0.00390625 113.868 -0.00390625 100.428C-0.00390625 86.9879 10.9062 76.0777 24.3448 76.0777H41.6335L29.4106 63.8521C19.9077 54.35 19.9077 38.9186 29.4106 29.4165C38.9134 19.9123 54.3434 19.9123 63.8463 29.4165L76.0694 41.642V24.3531C76.0694 10.9132 86.9825 0.00292969 100.421 0.00292969C113.86 0.00292969 124.77 10.9132 124.77 24.3531V41.642L136.996 29.4165C146.499 19.9123 161.929 19.9123 171.432 29.4165C180.935 38.9186 180.935 54.35 171.432 63.8521L159.206 76.0777H176.494C189.936 76.0777 200.846 86.9879 200.846 100.428C200.846 113.868 189.936 124.778 176.494 124.778H159.206L171.432 137.004C180.935 146.506 180.935 161.937 171.432 171.439C161.929 180.941 146.499 180.941 136.996 171.439L124.77 159.214V176.503C124.77 189.942 113.86 200.853 100.421 200.853C86.9825 200.853 76.0694 189.942 76.0694 176.503V159.214L63.8463 171.439C54.3434 180.941 38.9134 180.941 29.4106 171.439C19.9077 161.937 19.9077 146.506 29.4106 137.004L41.6335 124.778ZM75.6356 90.1609C77.0901 93.2822 77.9044 96.7601 77.9044 100.428C77.9044 104.093 77.0901 107.573 75.6356 110.693C78.8721 111.872 81.905 113.756 84.4983 116.35C87.0916 118.943 88.9768 121.976 90.154 125.211C93.2754 123.757 96.7539 122.945 100.421 122.945C104.088 122.945 107.567 123.757 110.685 125.211C111.865 121.976 113.75 118.943 116.344 116.35C118.934 113.756 121.97 111.872 125.204 110.693C123.749 107.573 122.938 104.093 122.938 100.428C122.938 96.7601 123.749 93.2822 125.204 90.1609C121.97 88.9837 118.934 87.0993 116.344 84.5057C113.75 81.9122 111.865 78.8795 110.685 75.6448C107.567 77.0982 104.088 77.9105 100.421 77.9105C96.7539 77.9105 93.2754 77.0982 90.154 75.6448C88.9768 78.8795 87.0916 81.9122 84.4983 84.5057C81.905 87.0993 78.8721 88.9837 75.6356 90.1609Z" fill="#FF8000"/><path d="M101.786 143.423C126.798 143.423 147.074 123.146 147.074 98.1346C147.074 73.1228 126.798 52.8467 101.786 52.8467C76.7742 52.8467 56.498 73.1228 56.498 98.1346C56.498 123.146 76.7742 143.423 101.786 143.423Z" fill="#FFC266"/><path fill-rule="evenodd" clip-rule="evenodd" d="M78.2756 89.2935C76.7565 88.4792 76.1874 86.5864 77.0004 85.0691C77.8135 83.5513 79.7092 82.9806 81.224 83.7949L94.8619 91.1129C95.8803 91.6591 96.5136 92.7238 96.505 93.8795C96.5007 95.0352 95.8545 96.0927 94.8318 96.6278L81.3523 103.67C79.8246 104.468 77.9376 103.876 77.1417 102.349C76.3415 100.823 76.9363 98.9364 78.4597 98.1389L86.7184 93.8253L78.2756 89.2935Z" fill="black"/><path fill-rule="evenodd" clip-rule="evenodd" d="M122.361 83.7949C123.876 82.9806 125.771 83.5513 126.585 85.0691C127.398 86.5864 126.828 88.4792 125.309 89.2935L116.867 93.8253L125.125 98.1389C126.649 98.9364 127.244 100.823 126.443 102.349C125.647 103.876 123.76 104.468 122.233 103.67L108.753 96.6278C107.73 96.0927 107.084 95.0352 107.08 93.8795C107.071 92.7238 107.705 91.6591 108.723 91.1129L122.361 83.7949Z" fill="black"/></svg>`,
  rom: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 183 205" fill="none"><path fill-rule="evenodd" clip-rule="evenodd" d="M33.2208 102.407C31.7154 101.669 30.2139 100.869 28.7219 100.009C6.20309 87.0317 -5.52423 65.1629 2.549 51.2032C10.6241 37.2434 35.4607 36.447 57.9796 49.4243C59.4697 50.2847 60.9142 51.1818 62.3076 52.1155C62.1956 50.4434 62.1386 48.7468 62.1386 47.0289C62.1386 21.0714 75.2479 -0.000976562 91.3962 -0.000976562C107.543 -0.000976562 120.652 21.0714 120.652 47.0289C120.652 48.7468 120.595 50.4434 120.483 52.1155C121.876 51.1818 123.321 50.2847 124.813 49.4243C147.332 36.447 172.168 37.2434 180.241 51.2032C188.315 65.1629 176.587 87.0317 154.07 100.009C152.578 100.869 151.077 101.669 149.57 102.407C151.077 103.146 152.578 103.945 154.07 104.806C176.587 117.783 188.315 139.652 180.241 153.611C172.168 167.571 147.332 168.368 124.813 155.39C123.321 154.53 121.876 153.633 120.483 152.699C120.595 154.371 120.652 156.068 120.652 157.789C120.652 183.743 107.543 204.815 91.3962 204.815C75.2479 204.815 62.1386 183.743 62.1386 157.789C62.1386 156.068 62.1956 154.371 62.3076 152.699C60.9142 153.633 59.4697 154.53 57.9796 155.39C35.4607 168.368 10.6241 167.571 2.549 153.611C-5.52423 139.652 6.20309 117.783 28.7219 104.806C30.2139 103.945 31.7154 103.146 33.2208 102.407ZM86.1248 93.293C85.7034 95.0231 85.0504 96.6769 84.1506 98.2331C83.2508 99.7892 82.1442 101.181 80.8534 102.407C82.1442 103.637 83.2508 105.028 84.1506 106.585C85.0504 108.138 85.7034 109.791 86.1248 111.522C87.8351 111.021 89.5967 110.759 91.3962 110.759C93.1957 110.759 94.9573 111.021 96.6676 111.522C97.0871 109.791 97.7401 108.138 98.6399 106.585C99.5397 105.028 100.648 103.637 101.937 102.407C100.648 101.181 99.5397 99.7892 98.6399 98.2331C97.7401 96.6769 97.0871 95.0231 96.6676 93.293C94.9573 93.7964 93.1957 94.0558 91.3962 94.0558C89.5967 94.0558 87.8351 93.7964 86.1248 93.293Z" fill="#0063FF"/><path d="M91.3947 147.431C116.305 147.431 136.498 127.273 136.498 102.407C136.498 77.5416 116.305 57.3838 91.3947 57.3838C66.4846 57.3838 46.291 77.5416 46.291 102.407C46.291 127.273 66.4846 147.431 91.3947 147.431Z" fill="#99CCFF"/><path d="M75.6552 108.064C79.429 108.064 82.4884 102.723 82.4884 96.1362C82.4884 89.549 79.429 84.209 75.6552 84.209C71.8814 84.209 68.8223 89.549 68.8223 96.1362C68.8223 102.723 71.8814 108.064 75.6552 108.064Z" fill="black"/><path d="M107.150 108.064C110.924 108.064 113.984 102.723 113.984 96.1362C113.984 89.549 110.924 84.209 107.150 84.209C103.377 84.209 100.317 89.549 100.317 96.1362C100.317 102.723 103.377 108.064 107.150 108.064Z" fill="black"/></svg>`,
};

// Site brand text colours, sampled from the --color-{org}-{500|600} oklch
// values in app/assets/css/tailwind.css. Used for the wordmark next to the
// logo lockup.
const WORDMARK_COLORS = {
  hanakai: "#393939",
  hanami: "#FF6C89",
  dry: "#FF8000",
  rom: "#0063FF",
};

const LOGO_DATA_URIS = Object.fromEntries(
  Object.entries(LOGO_SVGS).map(([org, svg]) => [
    org,
    `data:image/svg+xml;base64,${Buffer.from(svg).toString("base64")}`,
  ]),
);

// Renders the same sine-wave squiggle the site uses below section headers
// (see app/templates/svgs/_wiggle.html.erb). Computed once per org at module
// load and inlined as a data URI for Satori.
const WIGGLE_WIDTH = CONTENT_W;
const WIGGLE_HEIGHT = 20;
const WIGGLE_STROKE = 4;

function wiggleSvg(color) {
  const center = WIGGLE_HEIGHT / 2;
  const amp = WIGGLE_HEIGHT * 0.25;
  const top = center - amp;
  const bottom = center + amp;
  const wavelength = WIGGLE_HEIGHT * 0.9;
  const quarter = wavelength / 4;
  const half = wavelength / 2;
  const threeQuarter = wavelength * 0.75;
  const cycles = Math.ceil(WIGGLE_WIDTH / wavelength);
  let d = `M0,${center}`;
  for (let i = 0; i < cycles; i++) {
    const x = i * wavelength;
    d += ` Q${x + quarter},${top} ${x + half},${center} Q${x + threeQuarter},${bottom} ${x + wavelength},${center}`;
  }
  const fullW = cycles * wavelength;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${WIGGLE_WIDTH}" height="${WIGGLE_HEIGHT}" viewBox="0 0 ${fullW} ${WIGGLE_HEIGHT}" preserveAspectRatio="none"><path d="${d}" fill="none" stroke="${color}" stroke-width="${WIGGLE_STROKE}" stroke-linecap="round"/></svg>`;
}

const WIGGLE_DATA_URIS = Object.fromEntries(
  Object.entries(ACCENTS).map(([org, color]) => [
    org,
    `data:image/svg+xml;base64,${Buffer.from(wiggleSvg(color)).toString("base64")}`,
  ]),
);

const WORDMARKS = {
  hanakai: "Hanakai",
  hanami: "Hanami",
  dry: "Dry",
  rom: "Rom",
};

function el(type, style, children) {
  const props = { style };
  if (children !== undefined) props.children = children;
  return { type, props };
}

function img(src, width, height) {
  return {
    type: "img",
    props: {
      src,
      width,
      height,
      style: { width, height, display: "flex" },
    },
  };
}

function frame(org, body) {
  const key = org && ACCENTS[org] ? org : "hanakai";
  return el(
    "div",
    {
      width: "100%",
      height: "100%",
      display: "flex",
      backgroundColor: ACCENTS[key],
      padding: OUTER_PAD,
      fontFamily: FONT_FAMILY,
      color: TEXT,
    },
    [
      el(
        "div",
        {
          flex: 1,
          display: "flex",
          flexDirection: "column",
          backgroundColor: INNER_BG,
          borderRadius: INNER_RADIUS,
          padding: `56px ${INNER_PAD_X}px 52px ${INNER_PAD_X}px`,
        },
        [
          brandRow(key),
          el(
            "div",
            {
              marginTop: 28,
              display: "flex",
              width: "100%",
              flexShrink: 0,
            },
            [img(WIGGLE_DATA_URIS[key], WIGGLE_WIDTH, WIGGLE_HEIGHT)],
          ),
          ...body,
        ],
      ),
    ],
  );
}

// Pick a title size that keeps long titles inside the canvas without manual
// truncation. Tuned against ~150-character outliers in the existing post set.
function titleSize(title, base) {
  const len = title?.length || 0;
  if (len <= 28) return base;
  if (len <= 48) return Math.round(base * 0.85);
  if (len <= 80) return Math.round(base * 0.7);
  return Math.round(base * 0.6);
}

function brandRow(org) {
  const key = org && LOGO_DATA_URIS[org] ? org : "hanakai";
  return el(
    "div",
    {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      width: "100%",
      flexShrink: 0,
    },
    [
      el(
        "div",
        {
          display: "flex",
          alignItems: "center",
          gap: 14,
        },
        [
          img(LOGO_DATA_URIS[key], 56, org === "rom" ? 60 : 56),
          el(
            "div",
            {
              fontSize: 50,
              fontWeight: 900,
              letterSpacing: "-0.03em",
              color: WORDMARK_COLORS[key],
              display: "flex",
            },
            WORDMARKS[key],
          ),
        ],
      ),
      el(
        "div",
        {
          fontFamily: MONO_FAMILY,
          fontSize: 26,
          fontWeight: 600,
          color: TEXT_MUTED,
          letterSpacing: "0.04em",
          display: "flex",
        },
        URL_LABEL,
      ),
    ],
  );
}

function metaText(text, opts = {}) {
  return el(
    "div",
    {
      fontFamily: opts.mono ? MONO_FAMILY : FONT_FAMILY,
      fontSize: opts.size || 26,
      fontWeight: opts.weight ?? (opts.mono ? 600 : 400),
      color: opts.color || TEXT_MUTED,
      letterSpacing: opts.tracking || 0,
      textTransform: opts.upper ? "uppercase" : "none",
      display: "flex",
    },
    text,
  );
}

function postTemplate(data) {
  const { title, author, date, org } = data;
  const size = titleSize(title, 88);
  return frame(
    org,
    [
      el("div", { flex: 1, display: "flex" }),
      date ? metaText(date, { mono: true, size: 22, upper: true, tracking: "0.08em" }) : null,
      el(
        "div",
        {
          marginTop: 16,
          fontSize: size,
          fontWeight: 900,
          lineHeight: 1.05,
          letterSpacing: "-0.035em",
          color: TEXT,
          display: "flex",
        },
        title,
      ),
      author
        ? el(
            "div",
            {
              marginTop: 28,
              fontSize: 28,
              fontWeight: 500,
              color: TEXT_MUTED,
              display: "flex",
            },
            `By ${author}`,
          )
        : null,
    ].filter(Boolean),
  );
}

function pageTemplate(data) {
  const { title, subtitle, org } = data;
  const size = titleSize(title, 104);
  return frame(
    org || "hanakai",
    [
      el("div", { flex: 1, display: "flex" }),
      el(
        "div",
        {
          fontSize: size,
          fontWeight: 900,
          lineHeight: 1.02,
          letterSpacing: "-0.04em",
          color: TEXT,
          display: "flex",
        },
        title,
      ),
      subtitle
        ? el(
            "div",
            {
              marginTop: 24,
              fontSize: 32,
              fontWeight: 400,
              color: TEXT_MUTED,
              display: "flex",
            },
            subtitle,
          )
        : null,
    ].filter(Boolean),
  );
}

function guideTemplate(data) {
  const { version, guideTitle, pageTitle, isRoot, org, description } = data;
  const headline = isRoot ? guideTitle : pageTitle;
  const size = titleSize(headline, 96);
  const eyebrow = isRoot ? null : guideTitle;

  return frame(
    org,
    [
      el("div", { flex: 1, display: "flex" }),
      eyebrow
        ? metaText(eyebrow, {
            mono: true,
            size: 22,
            upper: true,
            tracking: "0.08em",
          })
        : null,
      el(
        "div",
        {
          marginTop: 16,
          fontSize: size,
          fontWeight: 900,
          lineHeight: 1.04,
          letterSpacing: "-0.04em",
          color: TEXT,
          display: "flex",
        },
        headline,
      ),
      description
        ? el(
            "div",
            {
              marginTop: 20,
              fontSize: 28,
              fontWeight: 400,
              lineHeight: 1.3,
              color: TEXT_MUTED,
              display: "flex",
            },
            description,
          )
        : null,
      version
        ? el(
            "div",
            {
              marginTop: 24,
              fontFamily: MONO_FAMILY,
              fontSize: 26,
              fontWeight: 600,
              color: TEXT_MUTED,
              display: "flex",
            },
            version,
          )
        : null,
    ].filter(Boolean),
  );
}

function defaultTemplate() {
  return pageTemplate({
    title: "Let your Ruby bloom",
    subtitle: "Ruby tools that help you write clearer, more maintainable apps",
    org: "hanakai",
  });
}

export const templates = {
  post: postTemplate,
  page: pageTemplate,
  guide: guideTemplate,
  default: defaultTemplate,
};
