package com.example.myapplication55;
public class ShapeAdapter extends ArrayAdapter<Shape> {
    private Context context;
    private List<Shape> shapeList;

    public ShapeAdapter(Context context, List<Shape> shapes) {
        super(context, 0, shapes);
        this.context = context;
        this.shapeList = shapes;
    }

    static class ViewHolder {
        ImageView imageView;
        TextView textView;
    }

    @NonNull
    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;

        if (convertView == null) {
            convertView = LayoutInflater.from(context).inflate(R.layout.grid_item_layout, parent, false);
            holder = new ViewHolder();
            holder.imageView = convertView.findViewById(R.id.grid_image);
            holder.textView = convertView.findViewById(R.id.grid_text);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        Shape shape = shapeList.get(position);
        holder.imageView.setImageResource(shape.getImageResId());
        holder.textView.setText(shape.getName());

        return convertView;
    }
}
